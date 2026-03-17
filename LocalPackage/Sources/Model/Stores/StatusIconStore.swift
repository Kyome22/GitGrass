/*
 StatusIconStore.swift
 Model

 Created by Takuto Nakamura on 2024/11/24.
 Copyright 2022 Takuto Nakamura

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

import AppKit
import DataSource
import Observation

@MainActor @Observable
public final class StatusIconStore: Composable {
    private let appStateClient: AppStateClient
    private let nsAlertClient: NSAlertClient
    private let userDefaultsRepository: UserDefaultsRepository
    private let contributionService: ContributionService
    private let logService: LogService

    @ObservationIgnored private var timerTask: Task<Void, Never>?
    @ObservationIgnored private var task: Task<Void, Never>?

    public var imageProperties: ImageProperties
    public var gitHubAccountNotFound: Bool
    public let action: (Action) async -> Void

    public var lastYearData: [[DayData]] {
        imageProperties.dayData
    }

    public var lastMonthData: [[DayData]] {
        imageProperties.dayData.suffix(5).map(\.self)
    }

    public var lastWeekData: [DayData] {
        imageProperties.dayData.flatMap(\.self).suffix(7).map(\.self)
    }

    public init(
        _ appDependencies: AppDependencies,
        imageProperties: ImageProperties = .default,
        gitHubAccountNotFound: Bool = false,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.appStateClient = appDependencies.appStateClient
        self.nsAlertClient = appDependencies.nsAlertClient
        self.userDefaultsRepository = .init(appDependencies.userDefaultsClient)
        self.contributionService = .init(appDependencies)
        self.logService = .init(appDependencies)
        self.imageProperties = imageProperties
        self.gitHubAccountNotFound = gitHubAccountNotFound
        self.action = action
    }

    deinit {
        task?.cancel()
        timerTask?.cancel()
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))
            task?.cancel()
            task = Task { [weak self, appStateClient] in
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { @MainActor @Sendable in
                        let values = appStateClient.withLock(\.cycleSubject.values)
                        for await _ in values {
                            self?.startTimer()
                        }
                    }
                    group.addTask { @MainActor @Sendable in
                        let values = appStateClient.withLock(\.imagePropertiesSubject.values)
                        for await value in values {
                            self?.imageProperties = value
                        }
                    }
                    group.addTask { @MainActor @Sendable in
                        let values = appStateClient.withLock(\.errorSubject.values)
                        for await value in values {
                            self?.handleError(value)
                        }
                    }
                    group.addTask { @MainActor @Sendable in
                        let publisher = NSWorkspace.shared.notificationCenter
                            .publisher(for: NSWorkspace.willSleepNotification)
                        for await _ in publisher.values {
                            self?.stopTimer()
                        }
                    }
                    group.addTask { @MainActor @Sendable in
                        let publisher = NSWorkspace.shared.notificationCenter
                            .publisher(for: NSWorkspace.didWakeNotification)
                        for await _ in publisher.values {
                            self?.startTimer()
                        }
                    }
                    group.addTask { @MainActor @Sendable in
                        let publisher = DistributedNotificationCenter.default()
                            .publisher(for: .NSAppleColorPreferencesChanged)
                        for await _ in publisher.values {
                            guard let self else { continue }
                            self.imageProperties = self.imageProperties
                        }
                    }
                }
            }
            startTimer()
            await contributionService.fetchContributions()

        case let .gitHubAccountNotFoundChanged(value, error):
            guard value else { return }
            if nsAlertClient.runModal(error) == .alertFirstButtonReturn {
                gitHubAccountNotFound = false
            }
        }
    }

    private func handleError(_ error: any Error) {
        if case ContributionRepository.OperationError.gitHubAccountNotFound = error {
            gitHubAccountNotFound = true
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func startTimer() {
        stopTimer()
        let interval = 60 * Double(userDefaultsRepository.cycle.rawValue)
        let timer = AsyncStream {
            try? await Task.sleep(for: .seconds(interval))
        }
        timerTask = Task {
            await withTaskGroup(of: Void.self) { group in
                for await _ in timer {
                    group.addTask {
                        await self.contributionService.fetchContributions()
                    }
                }
            }
        }
    }

    public enum Action: Sendable {
        case task(String)
        case gitHubAccountNotFoundChanged(Bool, NSError)
    }
}

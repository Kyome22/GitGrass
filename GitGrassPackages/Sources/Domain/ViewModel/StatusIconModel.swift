/*
 StatusIconModel.swift
 Domain

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

import DataLayer
import Observation
import SwiftUI

@MainActor @Observable public final class StatusIconModel {
    private let userDefaultsRepository: UserDefaultsRepository
    private let contributionService: ContributionService
    private let logService: LogService

    @ObservationIgnored private var timerTask: Task<Void, Never>?
    @ObservationIgnored private var task: Task<Void, Never>?

    public var imageProperties = ImageProperties.default
    public var gitHubAccountNotFound = false

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
        _ userDefaultsClient: UserDefaultsClient,
        _ contributionService: ContributionService,
        _ logService: LogService
    ) {
        self.userDefaultsRepository = .init(userDefaultsClient)
        self.contributionService = contributionService
        self.logService = logService
    }

    deinit {
        task?.cancel()
        timerTask?.cancel()
    }

    public func onAppear(screenName: String) {
        logService.notice(.screenView(name: screenName))
        task = Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    for await _ in await self.contributionService.cycleStream() {
                        await self.startTimer()
                    }
                }
                group.addTask {
                    for await value in await self.contributionService.imagePropertiesStream() {
                        await MainActor.run {
                            self.imageProperties = value
                        }
                    }
                }
                group.addTask {
                    for await value in await self.contributionService.errorStream() {
                        await self.handleError(value)
                    }
                }
                group.addTask {
                    let publisher = NSWorkspace.shared.notificationCenter
                        .publisher(for: NSWorkspace.willSleepNotification)
                    for await _ in publisher.values {
                        await self.stopTimer()
                    }
                }
                group.addTask {
                    let publisher = NSWorkspace.shared.notificationCenter
                        .publisher(for: NSWorkspace.didWakeNotification)
                    for await _ in publisher.values {
                        await self.startTimer()
                    }
                }
                group.addTask {
                    let publisher = DistributedNotificationCenter.default()
                        .publisher(for: .NSAppleColorPreferencesChanged)
                    for await _ in publisher.values {
                        await MainActor.run {
                            self.imageProperties = self.imageProperties
                        }
                    }
                }
            }
        }
        startTimer()
        Task {
            await contributionService.fetchGrass()
        }
    }

    public func onCloseAlert() {
        gitHubAccountNotFound = false
    }

    func handleError(_ error: any Error) {
        if case ContributionRepository.OperationError.gitHubAccountNotFound = error {
            gitHubAccountNotFound = true
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    func startTimer() {
        stopTimer()
        let interval = 60 * Double(userDefaultsRepository.cycle.rawValue)
        let timer = AsyncStream {
            try? await Task.sleep(for: .seconds(interval))
        }
        timerTask = Task {
            await withTaskGroup(of: Void.self) { group in
                for await _ in timer {
                    group.addTask {
                        await self.contributionService.fetchGrass()
                    }
                }
            }
        }
    }
}

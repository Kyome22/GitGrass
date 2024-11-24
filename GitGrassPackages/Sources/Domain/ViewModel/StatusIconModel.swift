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

import AppKit
import DataLayer
import Observation
import SwiftUI

@MainActor @Observable public final class StatusIconModel {
    private let userDefaultsRepository: UserDefaultsRepository
    private let contributionService: ContributionService
    private let logService: LogService

    private static let statusItem: NSStatusItem = {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.isVisible = false
        return statusItem
    }()

    @ObservationIgnored private var timerTask: Task<Void, Never>?
    @ObservationIgnored private var task: Task<Void, Never>?

    public var imageProperties = ImageProperties.default
    public var colorScheme = ColorScheme.light

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
            }
        }
        startTimer()
        Task {
            await contributionService.fetchGrass()
        }
    }

    public func onTask() async {
        guard let button = Self.statusItem.button else { return }
        let publisher = button
            .publisher(for: \.effectiveAppearance)
            .merge(with: NSApp.publisher(for: \.effectiveAppearance, options: .new))
            .debounce(for: 0.2, scheduler: RunLoop.main)
        for await _ in publisher.values {
            colorScheme = button.effectiveAppearance.isDark ? .dark : .light
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

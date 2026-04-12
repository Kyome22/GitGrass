/*
 AppDelegate.swift
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

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public let appDependencies = AppDependencies.shared

    public func applicationDidFinishLaunching(_ notification: Notification) {
        let appStateClient = appDependencies.appStateClient
        appStateClient.withLock {
            $0.name = Bundle.main.bundleName
            $0.version = Bundle.main.bundleVersion
        }
        let nsWorkspaceClient = appDependencies.nsWorkspaceClient
        let contributionService = ContributionService(appDependencies)
        let logService = LogService(appDependencies)
        logService.bootstrap()
        Task {
            await withTaskGroup { group in
                group.addTask {
                    let publisher = nsWorkspaceClient.publisher(NSWorkspace.willSleepNotification)
                    for await _ in publisher.values {
                        contributionService.stopPolling()
                    }
                }
                group.addTask {
                    let publisher = nsWorkspaceClient.publisher(NSWorkspace.didWakeNotification)
                    for await _ in publisher.values {
                        contributionService.startPolling()
                    }
                }
                group.addTask { @MainActor @Sendable in
                    let values = appStateClient.withLock(\.cycleSubject.values)
                    for await _ in values {
                        contributionService.startPolling()
                    }
                }
                group.addTask {
                    let values = appStateClient.withLock(\.errorSubject.values)
                    for await value in values {
                        let event = switch value {
                        case let .fetchContributionsFailed(error):
                            CriticalEvent.fetchContributionsFailed(error)
                        }
                        logService.critical(event)
                    }
                }
            }
        }
        logService.notice(.launchApp)
        contributionService.initializeSubject()
        contributionService.startPolling()
    }
}

/*
 AppDelegate.swift
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

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public let appDependencies = AppDependencies()
    public let appServices: AppServices

    public override init() {
        appServices = .init(appDependencies: appDependencies)
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        Task {
            await appServices.logService.bootstrap()
            appServices.logService.notice(.launchApp)
        }
        Task {
            for await error in await appServices.contributionService.errorStream() {
                appServices.logService.critical(.failedContribution(error))
            }
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {}
}
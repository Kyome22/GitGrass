/*
 AppDependencies.swift
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

import DataSource
import SwiftUI

public struct AppDependencies: Sendable {
    public var appStateClient = AppStateClient.liveValue
    public var distributedNotificationClient = DistributedNotificationClient.liveValue
    public var keychainClient = KeychainClient.liveValue
    public var loggingSystemClient = LoggingSystemClient.liveValue
    public var nsAppClient = NSAppClient.liveValue
    public var nsStatusBarClient = NSStatusBarClient.liveValue
    public var nsWorkspaceClient = NSWorkspaceClient.liveValue
    public var smAppServiceClient = SMAppServiceClient.liveValue
    public var urlSessionClient = URLSessionClient.liveValue
    public var userDefaultsClient = UserDefaultsClient.liveValue

    static let shared = AppDependencies()
}

extension EnvironmentValues {
    @Entry public var appDependencies = AppDependencies.shared
}

extension AppDependencies {
    public static func testDependencies(
        appStateClient: AppStateClient = .testValue,
        distributedNotificationClient: DistributedNotificationClient = .testValue,
        keychainClient: KeychainClient = .testValue,
        loggingSystemClient: LoggingSystemClient = .testValue,
        nsAppClient: NSAppClient = .testValue,
        nsStatusBarClient: NSStatusBarClient = .testValue,
        nsWorkspaceClient: NSWorkspaceClient = .testValue,
        smAppServiceClient: SMAppServiceClient = .testValue,
        urlSessionClient: URLSessionClient = .testValue,
        userDefaultsClient: UserDefaultsClient = .testValue
    ) -> AppDependencies {
        AppDependencies(
            appStateClient: appStateClient,
            distributedNotificationClient: distributedNotificationClient,
            keychainClient: keychainClient,
            loggingSystemClient: loggingSystemClient,
            nsAppClient: nsAppClient,
            nsStatusBarClient: nsStatusBarClient,
            nsWorkspaceClient: nsWorkspaceClient,
            smAppServiceClient: smAppServiceClient,
            urlSessionClient: urlSessionClient,
            userDefaultsClient:  userDefaultsClient
        )
    }
}

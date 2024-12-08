/*
 AppDependencies.swift
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
import SwiftUI

public final class AppDependencies: Sendable {
    public let dependencyListClient: DependencyListClient
    public let keychainClient: KeychainClient
    public let loggingSystemClient: LoggingSystemClient
    public let nsAppClient: NSAppClient
    public let nsStatusBarClient: NSStatusBarClient
    public let smAppServiceClient: SMAppServiceClient
    public let urlSessionClient: URLSessionClient
    public let userDefaultsClient: UserDefaultsClient

    public nonisolated init(
        dependencyListClient: DependencyListClient = .liveValue,
        keychainClient: KeychainClient = .liveValue,
        loggingSystemClient: LoggingSystemClient = .liveValue,
        nsAppClient: NSAppClient = .liveValue,
        nsStatusBarClient: NSStatusBarClient = .liveValue,
        smAppServiceClient: SMAppServiceClient = .liveValue,
        urlSessionClient: URLSessionClient = .liveValue,
        userDefaultsClient: UserDefaultsClient = .liveValue
    ) {
        self.dependencyListClient = dependencyListClient
        self.keychainClient = keychainClient
        self.loggingSystemClient = loggingSystemClient
        self.nsAppClient = nsAppClient
        self.nsStatusBarClient = nsStatusBarClient
        self.smAppServiceClient = smAppServiceClient
        self.urlSessionClient = urlSessionClient
        self.userDefaultsClient = userDefaultsClient
    }
}

struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue = AppDependencies(
        dependencyListClient: .testValue,
        keychainClient: .testValue,
        loggingSystemClient: .testValue,
        nsAppClient: .testValue,
        nsStatusBarClient: .testValue,
        smAppServiceClient: .testValue,
        urlSessionClient: .testValue,
        userDefaultsClient: .testValue
    )
}

public extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}

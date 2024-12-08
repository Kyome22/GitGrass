/*
 MenuBarScene.swift
 Presentation

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

import Domain
import SwiftUI

public struct MenuBarScene: Scene {
    @Environment(\.appDependencies) private var appDependencies
    @Environment(\.appServices) private var appServices

    public init() {}

    public var body: some Scene {
        MenuBarExtra {
            MenuView(
                dependencyListClient: appDependencies.dependencyListClient,
                nsAppClient: appDependencies.nsAppClient,
                logService: appServices.logService
            )
            .environment(\.displayScale, 2.0)
        } label: {
            StatusIcon(
                userDefaultsClient: appDependencies.userDefaultsClient,
                contributionService: appServices.contributionService,
                logService: appServices.logService
            )
            .environment(\.displayScale, 2.0)
        }
    }
}

/*
 AppAlertScene.swift
 UserInterface

 Created by Takuto Nakamura on 2026/03/20.
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

import Model
import SwiftUI

public struct AppAlertScene: Scene {
    @Environment(\.appDependencies) private var appDependencies

    public init() {}

    public var body: some Scene {
        _AppAlertScene(store: .init(appDependencies))
    }
}

private struct _AppAlertScene: Scene {
    @StateObject var store: AppAlertStore

    var body: some Scene {
        AlertScene(
            Text("alertTitle", bundle: .module),
            isPresented: $store.showingAlert,
            presenting: store.error,
            actions: { _ in },
            message: { error in
                Text(error.message)
            }
        )
    }
}

extension AppAlertStore: ObservableObject {}

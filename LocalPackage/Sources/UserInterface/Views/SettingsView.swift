/*
 SettingsView.swift
 UserInterface

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
import Model
import SwiftUI

struct SettingsView: View {
    @Environment(\.appDependencies) private var appDependencies

    var body: some View {
        TabView {
            GeneralSettingsView(store: .init(appDependencies))
                .tabItem {
                    Label {
                        Text("general", bundle: .module)
                    } icon: {
                        Image(systemName: "gear")
                    }
                }
            AccountSettingsView(store: .init(appDependencies))
                .tabItem {
                    Label {
                        Text("account", bundle: .module)
                    } icon: {
                        Image(systemName: "person")
                    }
                }
        }
        .accessibilityIdentifier("settings")
    }
}

#Preview {
    SettingsView()
        .environment(\.appDependencies, .testDependencies())
}

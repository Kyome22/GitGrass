/*
 MenuView.swift
 GitGrass

 Created by Takuto Nakamura on 2023/10/25.
 Copyright 2023 Takuto Nakamura

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

import SwiftUI

struct MenuView<MBM: MenuBarModel>: View {
    @EnvironmentObject private var menuBarModel: MBM

    var body: some View {
        VStack {
            if #available(macOS 14.0, *) {
                SettingsLink {
                    Text("settings")
                }
            } else {
                Button("settings") {
                    menuBarModel.openSettings()
                }
            }
            Divider()
            Button("aboutGitGrass") {
                menuBarModel.openAbout()
            }
            Button("licenses") {
                menuBarModel.openLicenses()
            }
            Button("quitGitGrass") {
                menuBarModel.terminateApp()
            }
        }
    }
}

#Preview {
    MenuView<PreviewMock.MenuBarModelMock>()
        .environmentObject(PreviewMock.MenuBarModelMock())
}

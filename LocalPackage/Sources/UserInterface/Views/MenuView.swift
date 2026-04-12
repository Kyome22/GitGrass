/*
 MenuView.swift
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
import LicenseList
import Model
import SwiftUI

struct MenuView: View {
    @StateObject var store: MenuStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            SettingsLink {
                Text("settings", bundle: .module)
            }
            .preActionButtonStyle {
                await store.send(.settingsLinkTapped)
            }
            Divider()
            Button {
                Task {
                    await store.send(.aboutButtonTapped(aboutBody))
                }
            } label: {
                Text("aboutApp", bundle: .module)
            }
            Button {
                Task {
                    await store.send(.licensesButtonTapped(.init(action: {
                        openWindow(id: $0, value: $1)
                    })))
                }
            } label: {
                Text("licenses", bundle: .module)
            }
            Button {
                Task {
                    await store.send(.quitButtonTapped)
                }
            } label: {
                Text("quitApp", bundle: .module)
            }
#if DEBUG
            Divider()
            Button {
                Task {
                    await store.send(.debugSleepButtonTapped)
                }
            } label: {
                Text("debugSleep", bundle: .module)
            }
            Button {
                Task {
                    await store.send(.debugWakeUpButtonTapped)
                }
            } label: {
                Text("debugWakeUp", bundle: .module)
            }
#endif
        }
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }

    private var aboutBody: AttributedString {
        var attributedString = AttributedString()

        var ossParagraph = AttributedString(String(localized: "oss", bundle: .module))
        ossParagraph.foregroundColor = NSColor.textColor
        attributedString.append(ossParagraph)

        let url = URL(string: "https://github.com/Kyome22/GitGrass")!
        var urlParagraph = AttributedString(url.absoluteString)
        urlParagraph.foregroundColor = NSColor(resource: .URL)
        urlParagraph.link = url
        attributedString.append(urlParagraph)

        return attributedString
    }
}

extension MenuStore: ObservableObject {}

#Preview {
    MenuView(store: .init(.testDependencies()))
}

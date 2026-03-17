/*
 GeneralSettingsView.swift
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

struct GeneralSettingsView: View {
    @StateObject var store: GeneralSettingsStore

    var body: some View {
        Form {
            personalAccessTokenField
            LabeledContent {
                HStack(spacing: 8) {
                    TextField(text: $store.username) {
                        EmptyView()
                    }
                    .labelsHidden()
                    .onSubmit {
                        Task {
                            await store.send(.usernameSubmitted)
                        }
                    }
                    .frame(width: 120)
                    Button {
                        Task {
                            await store.send(.updateButtonTapped)
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.borderless)
                }
            } label: {
                Text("accountName", bundle: .module)
            }
            Divider()
            pickerItem(
                labelKey: "updateCycle",
                selection: Binding<GGCycle>(
                    get: { store.cycle },
                    asyncSet: { await store.send(.cyclePickerSelected($0)) }
                )
            )
            pickerItem(
                labelKey: "color",
                selection: Binding<GGColor>(
                    get: { store.color },
                    asyncSet: { await store.send(.colorPickerSelected($0)) }
                )
            )
            pickerItem(
                labelKey: "style",
                selection: Binding<GGStyle>(
                    get: { store.style },
                    asyncSet: { await store.send(.stylePickerSelected($0)) }
                )
            )
            pickerItem(
                labelKey: "period",
                selection: Binding<GGPeriod>(
                    get: { store.period },
                    asyncSet: { await store.send(.periodPickerSelected($0)) }
                )
            )
            Divider()
            LabeledContent {
                Toggle(isOn: Binding<Bool>(
                    get: { store.launchAtLoginIsEnabled },
                    asyncSet: { await store.send(.launchAtLoginToggleSwitched($0)) }
                )) {
                    Text("AutomaticallyLaunchAtLogin", bundle: .module)
                }
            } label: {
                Text("launch", bundle: .module)
            }
        }
        .formStyle(.columns)
        .fixedSize()
    }

    private var personalAccessTokenField: some View {
        Group {
            if store.tokenIsAlreadyStored {
                LabeledContent {
                    Text(verbatim: store.personalAccessToken.secured)
                        .fontDesign(.monospaced)
                        .foregroundColor(.secondary)
                        .padding(2)
                        .border(Color.secondary.opacity(0.5))
                } label: {
                    Text("personalAccessToken", bundle: .module)
                }
            } else {
                TextField(text: $store.personalAccessToken) {
                    Text("personalAccessToken", bundle: .module)
                }
                .disableAutocorrection(true)
            }
            HStack {
                Text("scope", bundle: .module)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                if store.tokenIsAlreadyStored {
                    Button {
                        Task {
                            await store.send(.resetButtonTapped)
                        }
                    } label: {
                        Text("reset", bundle: .module)
                    }
                } else {
                    Button {
                        Task {
                            await store.send(.saveButtonTapped)
                        }
                    } label: {
                        Text("save", bundle: .module)
                    }
                    .disabled(store.personalAccessToken.isEmpty)
                }
            }
            .fixedSize()
        }
    }

    private func pickerItem<E: RawRepresentable & Hashable & CaseIterable & Localizable>(
        labelKey: LocalizedStringKey,
        selection: Binding<E>
    ) -> some View where E.RawValue == Int, E.AllCases == Array<E> {
        Picker(selection: selection) {
            ForEach(E.allCases, id: \.rawValue) { item in
                Text(item.label).tag(item)
            }
        } label: {
            Text(labelKey, bundle: .module)
        }
        .pickerStyle(.menu)
        .fixedSize()
    }
}

extension GeneralSettingsStore: ObservableObject {}

#Preview {
    GeneralSettingsView(store: .init(.testDependencies()))
}

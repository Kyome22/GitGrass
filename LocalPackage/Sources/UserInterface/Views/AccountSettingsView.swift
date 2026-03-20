/*
 AccountSettingsView.swift
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

import DataSource
import Model
import SwiftUI

struct AccountSettingsView: View {
    @StateObject var store: AccountSettingsStore

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    HStack {
                        if store.tokenIsAlreadyStored {
                            Text(verbatim: store.personalAccessToken.secured)
                                .fontDesign(.monospaced)
                                .foregroundColor(.secondary)
                                .padding(2)
                                .border(Color.secondary.opacity(0.5))
                            Button {
                                Task {
                                    await store.send(.resetButtonTapped)
                                }
                            } label: {
                                Text("reset", bundle: .module)
                            }
                        } else {
                            TextField(text: $store.personalAccessToken) {
                                EmptyView()
                            }
                            .textFieldStyle(.roundedBorder)
                            .disableAutocorrection(true)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
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
                } label: {
                    Text("personalAccessToken", bundle: .module)
                    Text("scope", bundle: .module)
                }
                LabeledContent {
                    HStack(spacing: 8) {
                        TextField(text: $store.username) {
                            EmptyView()
                        }
                        .textFieldStyle(.roundedBorder)
                        .labelsHidden()
                        .onSubmit {
                            Task {
                                await store.send(.usernameSubmitted)
                            }
                        }
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
                    Text("userName", bundle: .module)
                }
            } header: {
                Text("githubAccount", bundle: .module)
            }
        }
        .formStyle(.grouped)
        .fixedSize()
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }
}

extension AccountSettingsStore: ObservableObject {}

#Preview {
    AccountSettingsView(store: .init(.testDependencies()))
}

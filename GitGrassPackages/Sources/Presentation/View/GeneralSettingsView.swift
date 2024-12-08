/*
 GeneralSettingsView.swift
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

import DataLayer
import Domain
import SwiftUI

struct GeneralSettingsView: View {
    @State private var viewModel: GeneralSettingsViewModel

    init(
        keychainClient: KeychainClient,
        smAppServiceClient: SMAppServiceClient,
        userDefaultsClient: UserDefaultsClient,
        contributionService: ContributionService,
        logService: LogService
    ) {
        viewModel = .init(
            keychainClient,
            smAppServiceClient,
            userDefaultsClient,
            contributionService,
            logService
        )
    }

    var body: some View {
        Form {
            personalAccessTokenField
            LabeledContent {
                HStack(spacing: 8) {
                    TextField(text: $viewModel.username) {
                        EmptyView()
                    }
                    .labelsHidden()
                    .onSubmit {
                        viewModel.updateUsername()
                    }
                    .frame(width: 120)
                    Button {
                        viewModel.updateUsername()
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
                    get: { viewModel.cycle },
                    set: { viewModel.updateCycle($0) }
                )
            )
            pickerItem(
                labelKey: "color",
                selection: Binding<GGColor>(
                    get: { viewModel.color },
                    set: { viewModel.updateImageProperties(color: $0) }
                )
            )
            pickerItem(
                labelKey: "style",
                selection: Binding<GGStyle>(
                    get: { viewModel.style },
                    set: { viewModel.updateImageProperties(style: $0) }
                )
            )
            pickerItem(
                labelKey: "period",
                selection: Binding<GGPeriod>(
                    get: { viewModel.period },
                    set: { viewModel.updateImageProperties(period: $0) }
                )
            )
            Divider()
            LabeledContent {
                Toggle(isOn: Binding<Bool>(
                    get: { viewModel.launchAtLoginIsEnabled },
                    set: { viewModel.launchAtLoginSwitched($0) }
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
            if viewModel.tokenIsAlreadyStored {
                LabeledContent {
                    Text(verbatim: viewModel.personalAccessToken.secured)
                        .fontDesign(.monospaced)
                        .foregroundColor(.secondary)
                        .padding(2)
                        .border(Color.secondary.opacity(0.5))
                } label: {
                    Text("personalAccessToken", bundle: .module)
                }
            } else {
                TextField(text: $viewModel.personalAccessToken) {
                    Text("personalAccessToken", bundle: .module)
                }
                .disableAutocorrection(true)
            }
            HStack {
                Text("scope", bundle: .module)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                if viewModel.tokenIsAlreadyStored {
                    Button {
                        Task {
                            await viewModel.resetToken()
                        }
                    } label: {
                        Text("reset", bundle: .module)
                    }
                } else {
                    Button {
                        Task {
                            await viewModel.saveToken()
                        }
                    } label: {
                        Text("save", bundle: .module)
                    }
                    .disabled(viewModel.personalAccessToken.isEmpty)
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

#Preview {
    GeneralSettingsView(
        keychainClient: .testValue,
        smAppServiceClient: .testValue,
        userDefaultsClient: .testValue,
        contributionService: .init(.testValue, .testValue, .testValue),
        logService: .init(.testValue)
    )
}

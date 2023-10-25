/*
 GeneralSettingsView.swift
 GitGrass

 Created by Takuto Nakamura on 2022/10/11.
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

import SwiftUI

struct GeneralSettingsView<GVM: GeneralSettingsViewModel>: View {
    @StateObject var viewModel: GVM

    var body: some View {
        Form {
            personalAccessTokenField
            HStack(spacing: 8) {
                TextField("accountName", text: $viewModel.username)
                    .onSubmit {
                        viewModel.updateUsername()
                    }
                    .frame(width: 300)
                Button {
                    viewModel.updateUsername()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.borderless)
            }
            Divider()
            pickerItem(labelKey: "updateCycle",
                       selection: $viewModel.cycle)
            pickerItem(labelKey: "color",
                       selection: $viewModel.color)
            pickerItem(labelKey: "style",
                       selection: $viewModel.style)
            pickerItem(labelKey: "period",
                       selection: $viewModel.period)
            Divider()
            LabeledContent("launch") {
                Toggle(isOn: $viewModel.launchAtLogin) {
                    Text("launchAtLogin")
                }
            }
        }
        .fixedSize()
    }

    private var personalAccessTokenField: some View {
        Group {
            if viewModel.tokenIsAlreadyStored {
                LabeledContent("personalAccessToken") {
                    Text(verbatim: viewModel.personalAccessToken.secured)
                        .fontDesign(.monospaced)
                        .foregroundColor(.secondary)
                        .padding(2)
                        .border(Color.secondary.opacity(0.5))
                }
            } else {
                TextField("personalAccessToken", text: $viewModel.personalAccessToken)
                    .disableAutocorrection(true)
            }
            HStack {
                Text("scope")
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                if viewModel.tokenIsAlreadyStored {
                    Button("reset") {
                        viewModel.resetToken()
                    }
                } else {
                    Button("save") {
                        viewModel.saveToken()
                    }
                    .disabled(viewModel.personalAccessToken.isEmpty)
                }
            }
            .fixedSize()
        }
    }

    private func pickerItem<E: RawRepresentable & Hashable & CaseIterable & LocalizedEnum>(
        labelKey: LocalizedStringKey,
        selection: Binding<E>
    ) -> some View where E.RawValue == Int, E.AllCases == Array<E> {
        Picker(labelKey, selection: selection) {
            ForEach(E.allCases, id: \.rawValue) { item in
                Text(item.localizedKey).tag(item)
            }
        }
        .pickerStyle(.menu)
        .fixedSize()
    }
}

#Preview {
    ForEach(["en_US", "ja_JP"], id: \.self) { id in
        GeneralSettingsView(viewModel: PreviewMock.GeneralSettingsViewModelMock())
            .environment(\.locale, .init(identifier: id))
    }
}

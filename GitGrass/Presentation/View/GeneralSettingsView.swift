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

    init(viewModel: GVM) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("accountName")
                TextField("", text: $viewModel.username)
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
            pickerItem(summaryKey: "updateCycle",
                       selection: $viewModel.cycle)
            pickerItem(summaryKey: "color",
                       selection: $viewModel.color)
            pickerItem(summaryKey: "style",
                       selection: $viewModel.style)
            pickerItem(summaryKey: "period",
                       selection: $viewModel.period)
            if macOS13OrLater {
                Divider()
                HStack(alignment: .center, spacing: 8) {
                    wrapText(maxKey: "wrapText", key: "launch")
                    Toggle(isOn: $viewModel.launchAtLogin) {
                        Text("launchAtLogin")
                    }
                }
                .frame(height: 20)
            }
        }
        .fixedSize()
    }

    private func pickerItem<E: RawRepresentable & Hashable & CaseIterable & LocalizedEnum>(
        summaryKey: LocalizedStringKey,
        selection: Binding<E>
    ) -> some View where E.RawValue == Int, E.AllCases == Array<E> {
        HStack {
            wrapText(maxKey: "wrapText", key: summaryKey)
            Picker(selection: selection) {
                ForEach(E.allCases, id: \.rawValue) { item in
                    Text(item.localizedKey).tag(item)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.menu)
            .fixedSize(horizontal: true, vertical: false)
            Spacer()
        }
        .frame(height: 20)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["en_US", "ja_JP"], id: \.self) { id in
            GeneralSettingsView(viewModel: PreviewMock.GeneralSettingsViewModelMock())
                .environment(\.locale, .init(identifier: id))
        }
    }
}

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
            Section {
                pickerItem(
                    labelKey: "updateCycle",
                    selection: Binding<GGCycle>(
                        get: { store.cycle },
                        asyncSet: { await store.send(.cyclePickerSelected($0)) }
                    )
                )
            }
            Section {
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
            }
            Section {
                LabeledContent {
                    Toggle(isOn: Binding<Bool>(
                        get: { store.launchAtLoginIsEnabled },
                        asyncSet: { await store.send(.launchAtLoginToggleSwitched($0)) }
                    )) {
                        EmptyView()
                    }
                    .toggleStyle(.switch)
                } label: {
                    Text("launch", bundle: .module)
                    Text("AutomaticallyLaunchAtLogin", bundle: .module)
                }
            }
        }
        .formStyle(.grouped)
        .fixedSize()
        .task {
            await store.send(.task(String(describing: Self.self)))
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

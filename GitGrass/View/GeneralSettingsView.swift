//
//  GeneralSettingsView.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2022/10/11.
//  Copyright 2022 Takuto Nakamura
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI

struct GeneralSettingsView: View {
    @StateObject var viewModel = GeneralSettingsViewModel()

    var body: some View {
        VStack(alignment: .leading) {
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
            HStack {
                wrapText(maxKey: "accountName", key: "updateCycle")
                Picker(selection: $viewModel.cycle) {
                    ForEach(GGCycle.allCases, id: \.rawValue) { cycle in
                        Text(cycle.localizedKey).tag(cycle)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.menu)
                .fixedSize()
            }
            HStack {
                wrapText(maxKey: "accountName", key: "color")
                Picker(selection: $viewModel.color) {
                    ForEach(GGColor.allCases, id: \.rawValue) { color in
                        Text(color.localizedKey).tag(color)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.menu)
                .fixedSize()
            }
            HStack {
                wrapText(maxKey: "accountName", key: "style")
                Picker(selection: $viewModel.style) {
                    ForEach(GGStyle.allCases, id: \.rawValue) { style in
                        Text(style.localizedKey).tag(style)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.menu)
                .fixedSize()
            }
            HStack {
                wrapText(maxKey: "accountName", key: "period")
                Picker(selection: $viewModel.period) {
                    ForEach(GGPeriod.allCases, id: \.rawValue) { period in
                        Text(period.localizedKey).tag(period)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.menu)
                .fixedSize()
            }
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}

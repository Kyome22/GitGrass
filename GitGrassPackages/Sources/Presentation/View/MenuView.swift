/*
 MenuView.swift
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

struct MenuView: View {
    @State private var viewModel: MenuViewModel

    init(
        dependencyListClient: DependencyListClient,
        nsAppClient: NSAppClient,
        logService: LogService
    ) {
        viewModel = .init(dependencyListClient, nsAppClient, logService)
    }

    var body: some View {
        VStack {
            SettingsLink {
                Text("settings", bundle: .module)
            }
            .preActionButtonStyle {
                viewModel.activateApp()
            }
            Divider()
            Button {
                viewModel.openAbout(with: options)
            } label: {
                Text("aboutApp", bundle: .module)
            }
            Button {
                viewModel.openLicenses()
            } label: {
                Text("licenses", bundle: .module)
            }
            Button {
                viewModel.terminateApp()
            } label: {
                Text("terminateApp", bundle: .module)
            }
        }
        .onAppear {
            viewModel.onAppear(screenName: String(describing: Self.self))
        }
    }

    private var options: [NSApplication.AboutPanelOptionKey: Any] {
        let mutableAttrStr = NSMutableAttributedString()
        var attr: [NSAttributedString.Key : Any] = [.foregroundColor : NSColor.textColor]
        mutableAttrStr.append(NSAttributedString(string: String(localized: "oss", bundle: .module), attributes: attr))
        let url = "https://github.com/Kyome22/GitGrass"
        attr = [.foregroundColor : NSColor(resource: .URL), .link : url]
        mutableAttrStr.append(NSAttributedString(string: url, attributes: attr))
        return [.credits: mutableAttrStr]
    }
}

#Preview {
    MenuView(
        dependencyListClient: .testValue,
        nsAppClient: .testValue,
        logService: .init(.testValue)
    )
}

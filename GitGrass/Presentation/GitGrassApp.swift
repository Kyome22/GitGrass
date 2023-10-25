/*
 GitGrassApp.swift
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

@main
struct GitGrassApp: App {
    typealias UR = UserDefaultsRepositoryImpl
    typealias KR = KeychainRepositoryImpl
    typealias LR = LaunchAtLoginRepositoryImpl
    typealias CR = ContributionRepositoryImpl
    typealias CM = ContributionModelImpl<UR, KR, CR>
    typealias WM = WindowModelImpl
    typealias MBM = MenuBarModelImpl<UR, CM, WM>
    typealias GVM = GeneralSettingsViewModelImpl<UR, KR, LR>

    @StateObject private var appModel = GitGrassAppModelImpl()

    var body: some Scene {
        Settings {
            SettingsView<GitGrassAppModelImpl, GVM>()
                .environmentObject(appModel)
        }
        MenuBarExtra {
            MenuView<MBM>()
                .environmentObject(appModel.menuBarModel)
        } label: {
            StatusImage<MBM>()
                .environment(\.displayScale, 2.0)
                .environmentObject(appModel.menuBarModel)
        }
    }
}

//    isDarkHandler: { [weak self] in
//        return self?.statusItem.button?.superview?.effectiveAppearance.isDark ?? false
//    }
//    )

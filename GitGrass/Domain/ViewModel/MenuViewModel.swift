/*
 MenuBarModel.swift
 GitGrass

 Created by Takuto Nakamura on 2023/10/25.
 Copyright 2023 Takuto Nakamura

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

import AppKit

protocol MenuViewModel: ObservableObject {
    init(_ windowModel: WindowModel)

    func openSettings()
    func openAbout()
    func openLicenses()
    func terminateApp()
}

final class MenuViewModelImpl: MenuViewModel {
    private let windowModel: WindowModel

    init(_ windowModel: WindowModel) {
        self.windowModel = windowModel
    }

    func openSettings() {
        windowModel.openSettings()
    }

    func openAbout() {
        windowModel.openAbout()
    }

    func openLicenses() {
        windowModel.openLicenses()
    }

    func terminateApp() {
        NSApp.terminate(nil)
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class MenuViewModelMock: MenuViewModel {
        init(_ windowModel: WindowModel) {}
        init() {}

        func openSettings() {}
        func openAbout() {}
        func openLicenses() {}
        func terminateApp() {}
    }
}

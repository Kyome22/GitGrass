//
//  MenuBar.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//  Copyright 2023 Takuto Nakamura
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

import AppKit
import Combine
import SwiftUI

final class MenuBar<MM: MenuBarModel>: NSObject {
    private let statusItem = NSStatusItem.default
    private let menu = NSMenu()
    private let menuBarModel: MM
    private var cancellables = Set<AnyCancellable>()

    init(menuBarModel: MM) {
        self.menuBarModel = menuBarModel
        super.init()

        menu.addItem(title: "preferences".localized,
                     action: #selector(openPreferences(_:)),
                     target: self)
        menu.addSeparator()
        menu.addItem(title: "aboutGitGrass".localized,
                     action: #selector(openAbout(_:)),
                     target: self)
        menu.addItem(title: "quitGitGrass".localized,
                     action: #selector(terminateApp(_:)),
                     target: self)
        statusItem.menu = menu

        self.menuBarModel.imageInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageInfo in
                self?.updateStatusItemImage(imageInfo)
            }
            .store(in: &cancellables)
    }

    private func updateStatusItemImage(_ imageInfo: GGImageInfo) {
        statusItem.button?.image = NSImage(
            dayData: imageInfo.dayData,
            color: imageInfo.color,
            style: imageInfo.style,
            period: imageInfo.period,
            isDarkHandler: { [weak self] in
                return self?.statusItem.button?.superview?.effectiveAppearance.isDark ?? false
            }
        )
    }

    @objc func openPreferences(_ sender: Any?) {
        menuBarModel.openPreferences()
    }

    @objc func openAbout(_ sender: Any?) {
        menuBarModel.openAbout()
    }

    @objc func terminateApp(_ sender: Any?) {
        menuBarModel.terminateApp()
    }
}

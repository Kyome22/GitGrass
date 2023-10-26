/*
 WindowModel.swift
 GitGrass

 Created by Takuto Nakamura on 2023/01/27.
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
import Combine
import DependencyList

protocol WindowModel: AnyObject {
    func openSettings()
    func openAbout()
    func openLicenses()
}

final class WindowModelImpl: NSObject, WindowModel, NSWindowDelegate {
    private var licensesWindowController: NSWindowController?

    private var settingsWindow: NSWindow? {
        return NSApp.windows.first(where: { window in
            window.frameAutosaveName == "com_apple_SwiftUI_Settings_window"
        })
    }

    func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        guard let window = settingsWindow else { return }
        if window.canBecomeMain {
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func openAbout() {
        NSApp.activate(ignoringOtherApps: true)
        let mutableAttrStr = NSMutableAttributedString()
        var attr: [NSAttributedString.Key : Any] = [.foregroundColor : NSColor.textColor]
        mutableAttrStr.append(NSAttributedString(string: String(localized: "oss"), attributes: attr))
        let url = "https://github.com/Kyome22/GitGrass"
        attr = [.foregroundColor : NSColor(resource: .URL), .link : url]
        mutableAttrStr.append(NSAttributedString(string: url, attributes: attr))
        let key = NSApplication.AboutPanelOptionKey.credits
        NSApp.orderFrontStandardAboutPanel(options: [key: mutableAttrStr])
    }

    func openLicenses() {
        if licensesWindowController == nil {
            NSApp.activate(ignoringOtherApps: true)
            let window = DependencyListWindow()
            window.delegate = self
            licensesWindowController = NSWindowController(window: window)
            licensesWindowController?.showWindow(nil)
            window.center()
        } else {
            if let window = licensesWindowController?.window as? DependencyListWindow {
                NSApp.activate(ignoringOtherApps: true)
                window.orderFrontRegardless()
            }
        }
    }

    // MARK: NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window === licensesWindowController?.window {
            licensesWindowController = nil
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class WindowModelMock: WindowModel {
        func openSettings() {}
        func openAbout() {}
        func openLicenses() {}
    }
}

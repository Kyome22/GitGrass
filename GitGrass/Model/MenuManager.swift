//
//  MenuManager.swift
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

import Cocoa
import SwiftUI
import Combine

final class MenuManager: NSObject {
    static let shared = MenuManager()

    private let dataManager = DataManager.shared
    private let statusItem = NSStatusItem.default
    private let menu = NSMenu()
    private var timer: Timer?
    private var timerCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var dayData: [[DayData]] = DayData.default

    private override init() {
        super.init()
        menu.addItem(withTitle: "preferences".localized,
                     action: #selector(openPreferences(_:)),
                     keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "aboutGitGrass".localized,
                     action: #selector(openAbout(_:)),
                     keyEquivalent: "")
        menu.addItem(withTitle: "quitGitGrass".localized,
                     action: #selector(terminate(_:)),
                     keyEquivalent: "")
        menu.items.forEach { menuItem in
            menuItem.target = self
        }
        statusItem.menu = menu

        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.willSleepNotification)
            .sink { [weak self] _ in
                self?.stopTimer()
            }
            .store(in: &cancellables)
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didWakeNotification)
            .sink { [weak self] _ in
                self?.startTimer()
            }
            .store(in: &cancellables)

        if let superview = statusItem.button?.superview {
            superview.publisher(for: \.effectiveAppearance, options: .new)
                .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
                .removeDuplicates(by: { $0.isDark == $1.isDark })
                .sink { [weak self] _ in
                    self?.updateGrassImage()
                }
                .store(in: &cancellables)
        }

        startTimer()
        if dataManager.username.isEmpty {
            openPreferences(nil)
        }
    }

    @objc func openPreferences(_ sender: Any?) {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        NSApp.windows.forEach { window in
            if window.canBecomeMain {
                window.orderFrontRegardless()
                window.center()
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    @objc func openAbout(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        let mutableAttrStr = NSMutableAttributedString()
        var attr: [NSAttributedString.Key : Any] = [.foregroundColor : NSColor.textColor]
        mutableAttrStr.append(NSAttributedString(string: "oss".localized, attributes: attr))
        let url = "https://github.com/Kyome22/GitGrass"
        attr = [.foregroundColor : NSColor.url, .link : url]
        mutableAttrStr.append(NSAttributedString(string: url, attributes: attr))
        let key = NSApplication.AboutPanelOptionKey.credits
        NSApp.orderFrontStandardAboutPanel(options: [key: mutableAttrStr])
    }

    @objc func terminate(_ sender: Any?) {
        NSApp.terminate(nil)
    }

    func updateGrassImage() {
        guard let button = statusItem.button,
              let isDark = button.superview?.effectiveAppearance.isDark
        else { return }
        button.image = NSImage(dayData: dayData,
                               color: dataManager.color,
                               style: dataManager.style,
                               period: dataManager.period,
                               isDark: isDark)
    }

    func fetchGrass() {
        if dataManager.username.isEmpty {
            dayData = DayData.default
            updateGrassImage()
            return
        }
        GitAccess.getGrass(username: dataManager.username) { [weak self] response, error in
            if let response {
                self?.dayData = GrassParser.parse(html: response)
            } else {
                self?.dayData = DayData.default
            }
            DispatchQueue.main.async {
                self?.updateGrassImage()
            }
        }
    }

    func startTimer() {
        let interval = 60.0 * Double(dataManager.cycle.rawValue)
        timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .sink { [weak self] _ in
                self?.fetchGrass()
            }
    }

    func updateUsername(_ username: String) {
        dataManager.username = username
        fetchGrass()
    }

    func stopTimer() {
        timerCancellable?.cancel()
    }

    func updateCycle(_ cycle: GGCycle) {
        dataManager.cycle = cycle
        stopTimer()
        startTimer()
    }

    func updateColor(_ color: GGColor) {
        dataManager.color = color
        updateGrassImage()
    }

    func updateStyle(_ style: GGStyle) {
        dataManager.style = style
        updateGrassImage()
    }

    func updatePeriod(_ period: GGPeriod) {
        dataManager.period = period
        updateGrassImage()
    }
}

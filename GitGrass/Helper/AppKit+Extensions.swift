//
//  AppKit+Extensions.swift
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

import AppKit

extension Notification.Name {
    static let openWindow = Notification.Name("openWindow")
}

extension NSAppearance {
    var isDark: Bool {
        if self.name == .vibrantDark { return true }
        return self.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }
}

extension NSStatusItem {
    static var `default`: NSStatusItem {
        return NSStatusBar.system.statusItem(withLength: Self.variableLength)
    }
}

extension NSMenu {
    func addItem(title: String, action: Selector, target: AnyObject) {
        self.addItem(NSMenuItem(title: title, action: action, target: target))
    }

    func addSeparator() {
        self.addItem(NSMenuItem.separator())
    }
}

extension NSMenuItem {
    convenience init(title: String, action: Selector, target: AnyObject) {
        self.init(title: title, action: action, keyEquivalent: "")
        self.target = target
    }
}

extension NSColor {
    static let url = NSColor(named: "urlColor")!

    static func fillColor(_ level: Int, _ color: GGColor, _ isDark: Bool) -> NSColor {
        if color == .monochrome {
            return NSColor.black.withAlphaComponent(0.2 * CGFloat(level + 1))
        } else if color == .greenGrass {
            let grassColor = NSColor(named: "\(isDark ? "dark" : "light")-grass")!
            return grassColor.withAlphaComponent(0.2 * CGFloat(level + 1))
        } else {
            let accentColor = NSColor.controlAccentColor.usingColorSpace(NSColorSpace.deviceRGB)!
            return accentColor.withAlphaComponent(0.2 * CGFloat(level + 1))
        }
    }
}

extension NSImage {
    convenience init(
        dayData: [[DayData]],
        color: GGColor,
        style: GGStyle,
        period: GGPeriod,
        isDarkHandler: @escaping () -> Bool
    ) {
        switch period {
        case .lastYear:
            let width = 0.5 * CGFloat(5 * dayData[0].count - 1)
            self.init(size: CGSize(width: width, height: 18.0), flipped: false) { _ in
                let isDark = isDarkHandler()
                for i in (0 ..< 7) {
                    for j in (0 ..< dayData[i].count) {
                        NSColor.fillColor(dayData[i][j].level, color, isDark).setFill()
                        let rect = NSRect(x: 2.5 * CGFloat(j), y: 15.5 - 2.5 * CGFloat(i), width: 2.0, height: 2.0)
                        if style == .block {
                            NSBezierPath(rect: rect).fill()
                        } else if style == .dot {
                            NSBezierPath(ovalIn: rect).fill()
                        }
                    }
                }
                return true
            }
        case .thisWeek:
            let lastWeekData = dayData.sorted { $0.count < $1.count }.compactMap { $0.last }
            self.init(size: CGSize(width: 124.0, height: 18.0), flipped: false) { _ in
                let isDark = isDarkHandler()
                for i in (0 ..< lastWeekData.count) {
                    NSColor.fillColor(lastWeekData[i].level, color, isDark).setFill()
                    let rect = NSRect(x: 18.0 * CGFloat(i), y: 1.0, width: 16.0, height: 16.0)
                    if style == .block {
                        NSBezierPath(roundedRect: rect, xRadius: 4.0, yRadius: 4.0).fill()
                    } else if style == .dot {
                        NSBezierPath(ovalIn: rect).fill()
                    }
                }
                return true
            }
        }
        self.isTemplate = (color == .monochrome)
    }
}

//
//  Extensions.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/19.
//  Copyright 2019 Takuto Nakamura
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

extension NSMenuItem {
    public func setAction(target: AnyObject, selector: Selector) {
        self.target = target
        self.action = selector
    }
}

extension NSColor {
    static let url = NSColor(named: "urlColor")!
    static let grass0 = NSColor(named: "grass0")!
    static let grass25 = NSColor(named: "grass25")!
    static let grass50 = NSColor(named: "grass50")!
    static let grass75 = NSColor(named: "grass75")!
    static let grass100 = NSColor(named: "grass100")!
    static let grassDark0 = NSColor(named: "grassDark0")!
    static let grassDark25 = NSColor(named: "grassDark25")!
    static let grassDark50 = NSColor(named: "grassDark50")!
    static let grassDark75 = NSColor(named: "grassDark75")!
    static let grassDark100 = NSColor(named: "grassDark100")!
    
    static func fillColor(_ level: Int, _ style: Style, _ dark: Bool) -> NSColor {
        if style == .mono {
            let white: CGFloat = dark ? 1.0 : 0.0
            switch level {
            case 1: return NSColor(white: white, alpha: 0.4)
            case 2: return NSColor(white: white, alpha: 0.6)
            case 3: return NSColor(white: white, alpha: 0.8)
            case 4: return NSColor(white: white, alpha: 1.0)
            default: return NSColor(white: white, alpha: 0.2)
            }
        } else {
            switch level {
            case 1:  return dark ? NSColor.grassDark25 : NSColor.grass25
            case 2:  return dark ? NSColor.grassDark50 : NSColor.grass50
            case 3:  return dark ? NSColor.grassDark75 : NSColor.grass75
            case 4:  return dark ? NSColor.grassDark100 : NSColor.grass100
            default: return dark ? NSColor.grassDark0 : NSColor.grass0
            }
        }
    }
}

extension String {
    func match(_ pattern: String) -> String? {
        guard
            let regex = try? NSRegularExpression(pattern: pattern),
            let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count))
            else { return nil }
        return NSString(string: self).substring(with: matched.range(at: 0))
    }
    
    func trim(_ before: String, _ after: String) -> String {
        let new = self.replacingOccurrences(of: before, with: "")
        return new.replacingOccurrences(of: after, with: "")
    }
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}

extension NSAppearance {
    var isDark: Bool {
        if self.name == .vibrantDark { return true }
        guard #available(macOS 10.14, *) else { return false }
        return self.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }
}


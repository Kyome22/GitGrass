//
//  Extensions.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/19.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

extension NSMenuItem {
    public func setAction(target: AnyObject, selector: Selector) {
        self.target = target
        self.action = selector
    }
}

extension NSColor {
    static let url = NSColor(named: NSColor.Name("urlColor"))!
    static let grass0 = NSColor(named: NSColor.Name("grass0"))!
    static let grass25 = NSColor(named: NSColor.Name("grass25"))!
    static let grass50 = NSColor(named: NSColor.Name("grass50"))!
    static let grass75 = NSColor(named: NSColor.Name("grass75"))!
    static let grass100 = NSColor(named: NSColor.Name("grass100"))!
    static let grassDark0 = NSColor(named: NSColor.Name("grassDark0"))!
    static let grassDark25 = NSColor(named: NSColor.Name("grassDark25"))!
    static let grassDark50 = NSColor(named: NSColor.Name("grassDark50"))!
    static let grassDark75 = NSColor(named: NSColor.Name("grassDark75"))!
    static let grassDark100 = NSColor(named: NSColor.Name("grassDark100"))!
    
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

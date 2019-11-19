//
//  Extensions.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/19.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

extension NSMenuItem {
    public func setAction(target: AnyObject, isShow: Bool = false, selector: Selector) {
        self.state = isShow ? NSControl.StateValue.on : NSControl.StateValue.off
        self.target = target
        self.action = selector
    }
}

extension NSColor {
    static let url = NSColor(named: NSColor.Name("urlColor"))!
    static let mono0 = NSColor(white: 0.0, alpha: 0.2)
    static let mono25 = NSColor(white: 0.0, alpha: 0.4)
    static let mono50 = NSColor(white: 0.0, alpha: 0.6)
    static let mono75 = NSColor(white: 0.0, alpha: 0.8)
    static let mono100 = NSColor(white: 0.0, alpha: 1.0)
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
    
    static func fillColor(_ level: Int, _ style: String, _ dark: Bool) -> NSColor {
        if style == "mono" {
            switch level {
            case 1: return NSColor.mono25
            case 2: return NSColor.mono50
            case 3: return NSColor.mono75
            case 4: return NSColor.mono100
            default: return NSColor.mono0
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
}

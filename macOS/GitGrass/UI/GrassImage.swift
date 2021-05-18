//
//  GrassImage.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2021/05/18.
//  Copyright © 2021 Takuto Nakamura. All rights reserved.
//

import AppKit

enum Color: Int {
    case monochrome = 0
    case greenGrass = 1
    case accentColor = 2
}

enum Style: Int {
    case block = 0
    case dot = 1
}

extension NSImage {
    convenience init(dayData: [[DayData]], color: Color, style: Style, isDark: Bool) {
        let width = 0.5 * CGFloat(5 * dayData[0].count - 1)
        self.init(size: CGSize(width: width, height: 18.0))
        lockFocus()
        for i in (0 ..< 7) {
            for j in (0 ..< dayData[i].count) {
                NSColor.fillColor(dayData[i][j].level, color, isDark).setFill()
                let rect = NSRect(x: 2.5 * CGFloat(j),
                                  y: 15.5 - 2.5 * CGFloat(i),
                                  width: 2.0, height: 2.0)
                if style == .block {
                    NSBezierPath(rect: rect).fill()
                } else if style == .dot {
                    NSBezierPath(ovalIn: rect).fill()
                }
            }
        }
        unlockFocus()
        isTemplate = (color == .monochrome)
    }
}



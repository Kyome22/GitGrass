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

enum History: Int {
    case all = 0
    case thisWeek = 1
}

extension NSImage {
    convenience init(dayData: [[DayData]], color: Color, style: Style, isDark: Bool, history: History) {

        switch history {
        case .all:
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
        case .thisWeek:
            let height: CGFloat = 18.0
            let blockSize: CGFloat = 16.0
            let spacing: CGFloat = 2.0
            let cornerRadius: CGFloat = 6.0
            let width: CGFloat = (blockSize+spacing)*7.0
            self.init(size: CGSize(width: width, height: height))
            lockFocus()

            let lastWeekIndex: Int = dayData[0].count - 1
            for i in 0..<7 {
                if dayData[i].count > lastWeekIndex {
                    print(dayData[i][lastWeekIndex])
                    NSColor.fillColor(dayData[i][lastWeekIndex].level, color, isDark).setFill()
                } else {
                    NSColor(red: 0, green: 0, blue: 0, alpha: 0.2).setFill()
                }
                let rect = NSRect(x: (blockSize + spacing) * CGFloat(i),
                                  y: height/2 - blockSize/2,
                                  width: blockSize, height: blockSize)
                if style == .block {
                    NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius).fill()
                } else if style == .dot {
                    NSBezierPath(ovalIn: rect).fill()
                }
            }
        }

        unlockFocus()
        isTemplate = (color == .monochrome)
    }
}



//
//  GrassImage.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/20.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

class GrassImage {
    
    static func create(from dayData: [[DayData]], style: String, dark: Bool) -> NSImage {
        let width = CGFloat(5 * dayData[0].count - 1)
        let image = NSImage(size: NSSize(width: width, height: 36))
        image.lockFocus()
        if let context: CGContext = NSGraphicsContext.current?.cgContext {
            for i in (0 ..< 7) {
                for j in (0 ..< dayData[i].count) {
                    NSColor.fillColor(dayData[i][j].level, style, dark).setFill()
                    context.addRect(CGRect(x: j * 5, y: 31 - i * 5, width: 4, height: 4))
                    context.fillPath()
                }
            }
        }
        image.unlockFocus()
        image.size = NSSize(width: 0.5 * width, height: 18.0)
        if style == "mono" {
            image.isTemplate = true
        }        
        return image
    }
    
}

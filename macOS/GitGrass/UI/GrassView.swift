//
//  GrassView.swift
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

enum Color: Int {
    case monochrome = 0
    case greenGrass = 1
}

enum Style: Int {
    case block = 0
    case dot = 1
}

class GrassView: NSView {
    
    private var ao: NSKeyValueObservation?
    var dayData: [[DayData]] = DayData.default
    var color: Color = .monochrome
    var style: Style = .block
    
    init() {
        super.init(frame: NSRect(x: 3.0, y: 2.0, width: 124.5, height: 18.0))
        ao = self.observe(\.effectiveAppearance, changeHandler: { [weak self] (_, _) in
            self?.needsDisplay = true
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ao?.invalidate()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if dayData.isEmpty { return }
        let dark = self.effectiveAppearance.isDark
        for i in (0 ..< 7) {
            for j in (0 ..< dayData[i].count) {
                NSColor.fillColor(dayData[i][j].level, color, dark).setFill()
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
    }
    
    func update(_ dayData: [[DayData]], _ color: Color, _ style: Style) {
        self.dayData = dayData
        self.color = color
        self.style = style
        let width = 0.5 * CGFloat(5 * dayData[0].count - 1)
        self.frame.size = CGSize(width: width, height: 18.0)
        self.needsDisplay = true
    }
    
    func update(_ color: Color, _ style: Style) {
        self.color = color
        self.style = style
        self.needsDisplay = true
    }
    
}

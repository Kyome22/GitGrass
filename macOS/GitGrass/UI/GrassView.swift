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

enum Style: Int {
    case mono = 0
    case grass = 1
}

class GrassView: NSView {
    
    private var ao: NSKeyValueObservation?
    var dayData = [[DayData]]()
    var style: Style = .mono
    
    init() {
        super.init(frame: NSRect(x: 0, y: 2, width: 10, height: 18))
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
                NSColor.fillColor(dayData[i][j].level, style, dark).setFill()
                let rect = NSRect(x: 2.5 * CGFloat(j),
                                  y: 15.5 - 2.5 * CGFloat(i),
                                  width: 2.0, height: 2.0)
                let path = NSBezierPath(rect: rect)
                path.fill()
            }
        }
    }
    
    func update(dayData: [[DayData]], style: Style) {
        self.dayData = dayData
        self.style = style
        let width = 0.5 * CGFloat(5 * dayData[0].count - 1)
        self.frame.size = CGSize(width: width, height: 18.0)
        self.needsDisplay = true
    }
    
}

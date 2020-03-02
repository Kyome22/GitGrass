//
//  GrassView.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2020/03/02.
//  Copyright © 2020 Takuto Nakamura. All rights reserved.
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

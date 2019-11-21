//
//  GrassView.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/21.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import UIKit

class GrassView: UIView {
    var dayData = [[DayData]]()
    var w: CGFloat { return self.frame.width }
    var h: CGFloat { return self.frame.height }
    var isEX: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        if dayData.isEmpty { return }
        let t: CGFloat = h / 51.0
        for i in (0 ..< 7) {
            for j in (0 ..< dayData[i].count) {
                UIColor.fillColor(dayData[i][j].level, isEX).setFill()
                let margin = 0.5 * (w - CGFloat(7 * dayData[0].count) * t)
                let rect = CGRect(x: margin + CGFloat(j * 7) * t,
                                  y: CGFloat(2 + i * 7) * t,
                                  width: 5.0 * t,
                                  height: 5.0 * t)
                let path = UIBezierPath(rect: rect)
                path.fill()
            }
        }
    }
    
    func update(by dayData: [[DayData]], isEX: Bool) {
        self.dayData = dayData
        self.isEX = isEX
        self.setNeedsDisplay()
    }
    
}

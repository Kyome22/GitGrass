//
//  GrassView.swift
//  GitGrass-iOS
//
//  Created by Takuto Nakamura on 2020/03/22.
//  Copyright 2020 Takuto Nakamura
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

import UIKit

enum Color: Int {
    case greenGrass = 0
    case monochrome = 1
}

enum Style: Int {
    case block = 0
    case dot = 1
    case grass = 2
}

class GrassView: UIView {
    
    var dayData: [[DayData]] = DayData.default
    var color = Color.greenGrass
    var style = Style.block
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        if dayData.isEmpty { return }
        let isDark = self.traitCollection.isDark
        let ratio: CGFloat = bounds.height / 51.0 // 5 * 7  + 2 * 8 = 51
        for i in (0 ..< 7) {
            for j in (0 ..< dayData[i].count) {
                UIColor.grassColor(dayData[i][j].level, color, isDark).set()
                let rect = CGRect(x: ratio * CGFloat(2 + 7 * j),
                                  y: ratio * CGFloat(2 + 7 * i),
                                  width: 5.0 * ratio, height: 5.0 * ratio)
                switch style {
                case .block:
                    let path = UIBezierPath(rect: rect)
                    path.fill()
                case .dot:
                    let path = UIBezierPath(ovalIn: rect)
                    path.fill()
                case.grass:
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: rect.minX + ratio, y: rect.maxY))
                    path.addCurve(to: CGPoint(x: rect.minX, y: rect.minY + 2.0 * ratio),
                                  controlPoint1: CGPoint(x: rect.minX + ratio, y: rect.maxY - ratio),
                                  controlPoint2: CGPoint(x: rect.minX + 1.2 * ratio, y: rect.maxY - 1.8 * ratio))
                    path.addCurve(to: CGPoint(x: rect.minX + 1.8 * ratio, y: rect.maxY - 1.2 * ratio),
                                  controlPoint1: CGPoint(x: rect.minX + 0.9 * ratio, y: rect.minY + 2.3 * ratio),
                                  controlPoint2: CGPoint(x: rect.minX + 1.4 * ratio, y: rect.maxY - 2.0 * ratio))
                    path.addCurve(to: CGPoint(x: rect.minX + 0.8 * ratio, y: rect.minY + ratio),
                                  controlPoint1: CGPoint(x: rect.minX + 1.7 * ratio, y: rect.midY + 0.2 * ratio),
                                  controlPoint2: CGPoint(x: rect.minX + 1.5 * ratio, y: rect.minY + 2.1 * ratio))
                    path.addCurve(to: CGPoint(x: rect.minX + 2.4 * ratio, y: rect.midY),
                                  controlPoint1: CGPoint(x: rect.minX + 1.7 * ratio, y: rect.minY + 1.4 * ratio),
                                  controlPoint2: CGPoint(x: rect.minX + 2.2 * ratio, y: rect.minY + 2.1 * ratio))
                    path.addCurve(to: CGPoint(x: rect.maxX - 0.8 * ratio, y: rect.minY),
                                  controlPoint1: CGPoint(x: rect.maxX - 2.3 * ratio, y: rect.minY + 1.6 * ratio),
                                  controlPoint2: CGPoint(x: rect.maxX - 1.8 * ratio, y: rect.minY + 0.6 * ratio))
                    path.addCurve(to: CGPoint(x: rect.maxX - 1.8 * ratio, y: rect.maxY - 1.2 * ratio),
                                  controlPoint1: CGPoint(x: rect.maxX - 1.6 * ratio, y: rect.minY + 1.2 * ratio),
                                  controlPoint2: CGPoint(x: rect.maxX - 1.8 * ratio, y: rect.minY + 2.3 * ratio))
                    path.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 1.5 * ratio),
                                  controlPoint1: CGPoint(x: rect.maxX - 1.5 * ratio, y: rect.midY),
                                  controlPoint2: CGPoint(x: rect.maxX - 0.8 * ratio, y: rect.minY + 1.8 * ratio))
                    path.addCurve(to: CGPoint(x: rect.maxX - ratio, y: rect.maxY),
                                  controlPoint1: CGPoint(x: rect.maxX - 0.9 * ratio, y: rect.midY),
                                  controlPoint2: CGPoint(x: rect.maxX - ratio, y: rect.maxY - ratio))
                    path.close()
                    path.fill()
                }
            }
        }
    }
    
    func update(_ dayData: [[DayData]], _ color: Color, _ style: Style) {
        self.dayData = dayData
        self.color = color
        self.style = style
        self.setNeedsDisplay()
    }

}

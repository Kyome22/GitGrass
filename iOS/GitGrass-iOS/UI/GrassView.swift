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

class GrassView: UIView {
    
    var dayData: [[DayData]] = DayData.default
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        if dayData.isEmpty { return }
        let ratio: CGFloat = bounds.height / 51.0 // 5 * 7  + 2 * 8 = 51
        for i in (0 ..< 7) {
            for j in (0 ..< dayData[i].count) {
                let rect = CGRect(x: ratio * CGFloat(2 + 7 * j),
                                  y: ratio * CGFloat(2 + 7 * i),
                                  width: 5.0 * ratio, height: 5.0 * ratio)
                let path = UIBezierPath(rect: rect)
                UIColor.grassColor(dayData[i][j].level).setFill()
                path.fill()
            }
        }
    }
    
    func update(with dayData: [[DayData]]) {
        self.dayData = dayData
        self.setNeedsDisplay()
    }

}

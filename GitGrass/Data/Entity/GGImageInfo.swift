//
//  GGImageInfo.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/27.
//  Copyright 2023 Takuto Nakamura
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

import Foundation

struct GGImageInfo {
    var dayData: [[DayData]]
    var color: GGColor
    var style: GGStyle
    var period: GGPeriod

    init(_ dayData: [[DayData]], _ color: GGColor, _ style: GGStyle, _ period: GGPeriod) {
        self.dayData = dayData
        self.color = color
        self.style = style
        self.period = period
    }

    static let mock = GGImageInfo(DayData.default, .monochrome, .block, .lastYear)
}

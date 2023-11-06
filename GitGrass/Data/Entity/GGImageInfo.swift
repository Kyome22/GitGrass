/*
 GGImageInfo.swift
 GitGrass

 Created by Takuto Nakamura on 2023/01/27.
 Copyright 2023 Takuto Nakamura

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

import SwiftUI

struct GGImageInfo: Identifiable {
    var id = UUID()
    var dayData: [[DayData]]
    var color: GGColor
    var style: GGStyle
    var period: GGPeriod

    var renderingMode: Image.TemplateRenderingMode {
        switch color {
        case .monochrome:  return .template
        case .greenGrass:  return .original
        case .accentColor: return .original
        }
    }

    init(dayData: [[DayData]], color: GGColor, style: GGStyle, period: GGPeriod) {
        self.dayData = dayData
        self.color = color
        self.style = style
        self.period = period
    }

    func fillColor(level: Int, isDark: Bool) -> Color {
        let fillColor: Color
        switch color {
        case .monochrome:  fillColor = Color.black
        case .greenGrass:  fillColor = isDark ? Color(.grassDark) : Color(.grassLight)
        case .accentColor: fillColor = Color(nsColor: NSColor.controlAccentColor)
        }
        return fillColor.opacity(0.2 * Double(level + 1))
    }

    static let `default` = GGImageInfo(dayData: DayData.default,
                                       color: .monochrome,
                                       style: .block,
                                       period: .lastYear)
}

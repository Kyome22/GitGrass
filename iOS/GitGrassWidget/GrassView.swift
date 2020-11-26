//
//  GrassView.swift
//  GitGrassWidgetExtension
//
//  Created by Takuto Nakamura on 2020/10/04.
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

import SwiftUI

extension Color {

    static func grassColor(level: Int, color: GGColor) -> Color {
        if color == .greenGrass {
            return Color("grass-\(level)")
        } else { // .monochrome
            return Color("mono-\(level)")
        }
    }

}

struct GrassView: View {
    let dayData: [[DayData]]
    let size: CGSize
    let color: GGColor
    let style: GGStyle

    var body: some View {
        return VStack(alignment: .leading, spacing: 2) {
            ForEach(0 ..< 7) { i in
                self.makeRow(i: i)
            }
        }
    }

    private func makeRow(i: Int) -> some View {
        let range: Range<Int> = (dayData[0].count - 22 ..< dayData[i].count)
        return HStack(alignment: .top, spacing: 3) {
            ForEach(range) { j in
                self.makeShape(level: dayData[i][j].level)
            }
        }
    }

    private func makeShape(level: Int) -> some View {
        let r = floor((size.width + 3.0) / 22.0 - 3.0)
        let fillColor = Color.grassColor(level: level, color: color)
        return Group {
            if style == .block {
                BlockShape().fill(fillColor)
            } else if style == .dot {
                DotShape().fill(fillColor)
            } else {
                GrassShape().fill(fillColor)
            }
        }
        .frame(width: r, height: r)
    }
}

/*
 StatusIcon.swift
 GitGrass

 Created by Takuto Nakamura on 2023/10/25.
 Copyright 2022 Takuto Nakamura

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

struct StatusIcon<SIM: StatusIconModel>: View {
    @StateObject var viewModel: SIM

    var body: some View {
        Group {
            if viewModel.imageInfo.period == .lastWeek {
                lastWeekImage(viewModel.imageInfo)
            } else {
                lastMonthOrLastYear(viewModel.imageInfo)
            }
        }
        .onAppear {
            viewModel.setAppearanceObserver()
        }
    }

    func lastWeekImage(_ imageInfo: GGImageInfo) -> Image {
        let lastWeekData = Array(imageInfo.dayData.flatMap { $0 }.suffix(7))
        return Image(size: CGSize(width: 26.0, height: 18.0)) { context in
            for i in (0 ..< lastWeekData.count) {
                let level = lastWeekData[i].level
                let power = 0.2 * CGFloat(level + 1)
                let rect = CGRect(x: 4.0 * CGFloat(i), y: 8.0 * (1.0 - power), width: 2.0, height: 16.0 * power)
                let fillColor = imageInfo.fillColor(level: lastWeekData[i].level,
                                                    isDark: viewModel.isDark)
                switch imageInfo.style {
                case .block:
                    context.fill(Path(rect), with: .color(fillColor))
                case .dot:
                    context.fill(Path(roundedRect: rect, cornerRadius: 1.0), with: .color(fillColor))
                }
            }
        }
        .renderingMode(imageInfo.renderingMode)
    }

    func lastMonthOrLastYear(_ imageInfo: GGImageInfo) -> Image {
        var dayData = imageInfo.dayData
        if imageInfo.period == .lastMonth {
            dayData = Array(dayData.suffix(5))
        }
        let width = 0.5 * CGFloat(5 * dayData.count - 1)
        return Image(size: CGSize(width: width, height: 18.0)) { context in
            (0 ..< dayData.count).forEach { i in
                (0 ..< dayData[i].count).forEach { j in
                    let rect = CGRect(x: 2.5 * CGFloat(i), y: 0.5 + 2.5 * CGFloat(j), width: 2.0, height: 2.0)
                    let fillColor = imageInfo.fillColor(level: dayData[i][j].level,
                                                        isDark: viewModel.isDark)
                    switch imageInfo.style {
                    case .block:
                        context.fill(Path(rect), with: .color(fillColor))
                    case .dot:
                        context.fill(Path(ellipseIn: rect), with: .color(fillColor))
                    }
                }
            }
        }
        .renderingMode(imageInfo.renderingMode)
    }
}

#Preview {
    StatusIcon(viewModel: PreviewMock.StatusIconModelMock())
}

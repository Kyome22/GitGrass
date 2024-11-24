/*
 StatusIcon.swift
 Presentation

 Created by Takuto Nakamura on 2024/11/24.
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

import DataLayer
import Domain
import SwiftUI

struct StatusIcon: View {
    @State private var viewModel: StatusIconModel

    init(
        userDefaultsClient: UserDefaultsClient,
        contributionService: ContributionService,
        logService: LogService
    ) {
        viewModel = .init(userDefaultsClient, contributionService, logService)
    }

    var body: some View {
        Group {
            if viewModel.imageProperties.period == .lastWeek {
                lastWeekImage(viewModel.imageProperties)
            } else {
                lastMonthOrLastYear(viewModel.imageProperties)
            }
        }
        .onAppear {
            viewModel.onAppear(screenName: String(describing: Self.self))
        }
    }

    private func lastWeekImage(_ imageProperties: ImageProperties) -> Image {
        let lastWeekData = Array(imageProperties.dayData.flatMap(\.self).suffix(7))
        return Image(size: CGSize(width: 26.0, height: 18.0)) { context in
            (0 ..< lastWeekData.count).forEach { i in
                let level = lastWeekData[i].level
                let power = 0.2 * CGFloat(level + 1)
                let rect = CGRect(x: 4.0 * CGFloat(i), y: 8.0 * (1.0 - power), width: 2.0, height: 16.0 * power)
                let fillColor = imageProperties.fillColor(level: lastWeekData[i].level)
                switch imageProperties.style {
                case .block:
                    context.fill(Path(rect), with: .color(fillColor))
                case .dot:
                    context.fill(Path(roundedRect: rect, cornerRadius: 1.0), with: .color(fillColor))
                }
            }
        }
        .renderingMode(imageProperties.renderingMode)
    }

    private func lastMonthOrLastYear(_ imageProperties: ImageProperties) -> Image {
        let dayData: [[DayData]] = if imageProperties.period == .lastMonth {
            Array(imageProperties.dayData.suffix(5))
        } else {
            imageProperties.dayData
        }
        let width = 0.5 * CGFloat(5 * dayData.count - 1)
        return Image(size: CGSize(width: width, height: 18.0)) { context in
            (0 ..< dayData.count).forEach { i in
                (0 ..< dayData[i].count).forEach { j in
                    let rect = CGRect(x: 2.5 * CGFloat(i), y: 0.5 + 2.5 * CGFloat(j), width: 2.0, height: 2.0)
                    let fillColor = imageProperties.fillColor(level: dayData[i][j].level)
                    let path: Path = switch imageProperties.style {
                    case .block: Path(rect)
                    case .dot: Path(ellipseIn: rect)
                    }
                    context.fill(path, with: .color(fillColor))
                }
            }
        }
        .renderingMode(imageProperties.renderingMode)
    }
}

#Preview {
    StatusIcon(
        userDefaultsClient: .testValue,
        contributionService: .init(.testValue, .testValue, .testValue),
        logService: .init(.testValue)
    )
}

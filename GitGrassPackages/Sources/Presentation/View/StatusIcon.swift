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
            switch viewModel.imageProperties.period {
            case .lastYear:
                twoDimentionalImage(viewModel.lastYearData)
            case .lastMonth:
                twoDimentionalImage(viewModel.lastMonthData)
            case .lastWeek:
                oneDimentionalImage(viewModel.lastWeekData)
            }
        }
        .onAppear {
            viewModel.onAppear(screenName: String(describing: Self.self))
        }
        .onChange(of: viewModel.gitHubAccountNotFound) { _, newValue in
            if newValue {
                showAlert()
            }
        }
    }

    private func twoDimentionalImage(_ dayData: [[DayData]]) -> Image {
        let width = 0.5 * CGFloat(5 * dayData.count - 1)
        let nsImage = NSImage(size: CGSize(width: width, height: 18), flipped: true) { _ in
            dayData.indices.forEach { i in
                dayData[i].indices.forEach { j in
                    let level = dayData[i][j].level
                    let rect = CGRect(x: 2.5 * CGFloat(i), y: 0.5 + 2.5 * CGFloat(j), width: 2, height: 2)
                    viewModel.imageProperties.fillColor(level: level).setFill()
                    switch viewModel.imageProperties.style {
                    case .block:
                        NSBezierPath(rect: rect).fill()
                    case .dot:
                        NSBezierPath(ovalIn: rect).fill()
                    }
                }
            }
            return true
        }
        nsImage.isTemplate = viewModel.imageProperties.isTemplate
        return Image(nsImage: nsImage)
    }

    private func oneDimentionalImage(_ dayData: [DayData]) -> Image {
        let nsImage = NSImage(size: CGSize(width: 26, height: 18), flipped: true) { _ in
            dayData.indices.forEach { i in
                let level = dayData[i].level
                let power = 0.2 * CGFloat(level + 1)
                let rect = CGRect(x: 4 * CGFloat(i), y: 8 * (1 - power), width: 2, height: 16 * power)
                viewModel.imageProperties.fillColor(level: level).setFill()
                switch viewModel.imageProperties.style {
                case .block:
                    NSBezierPath(rect: rect).fill()
                case .dot:
                    NSBezierPath(roundedRect: rect, xRadius: 1, yRadius: 1).fill()
                }
            }
            return true
        }
        nsImage.isTemplate = viewModel.imageProperties.isTemplate
        return Image(nsImage: nsImage)
    }

    private func showAlert() {
        let nsError = NSError(
            domain: Bundle.main.bundleIdentifier!,
            code: 1,
            userInfo: [
                NSLocalizedDescriptionKey: String(localized: "accountNotFound", bundle: .module),
                NSLocalizedRecoverySuggestionErrorKey: String(localized: "checkAccountName", bundle: .module)
            ]
        )
        let result = NSAlert(error: nsError).runModal()
        if result == .alertFirstButtonReturn {
            viewModel.onCloseAlert()
        }
    }
}

#Preview {
    StatusIcon(
        userDefaultsClient: .testValue,
        contributionService: .init(.testValue, .testValue, .testValue),
        logService: .init(.testValue)
    )
}

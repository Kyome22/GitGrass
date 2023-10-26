/*
 StatusIconModel.swift
 GitGrass

 Created by Takuto Nakamura on 2023/10/25.
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
import Combine

protocol StatusIconModel: ObservableObject {
    var imageInfo: GGImageInfo { get set }
    var isDark: Bool { get set }

    init(_ userDefaultsRepository: UserDefaultsRepository,
         _ contributionModel: ContributionModel)

    func setAppearanceObserver()
}

final class StatusIconModelImpl: StatusIconModel {
    @Published var imageInfo = GGImageInfo(DayData.default, .monochrome, .block, .lastYear)
    @Published var isDark: Bool = false

    private var imageInfoCancellable: AnyCancellable?
    private var appearanceCancellable: AnyCancellable?

    init(
        _ userDefaultsRepository: UserDefaultsRepository,
        _ contributionModel: ContributionModel
    ) {
        let properties = GGProperties(userDefaultsRepository.color,
                                      userDefaultsRepository.style,
                                      userDefaultsRepository.period)
        imageInfoCancellable = userDefaultsRepository
            .propertiesPublisher
            .prepend(properties)
            .combineLatest(contributionModel.dayDataPublisher)
            .map { ($1, $0.0, $0.1, $0.2) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (dayData, color, style, period) in
                self?.imageInfo = GGImageInfo(dayData, color, style, period)
            }
    }

    func setAppearanceObserver() {
        if appearanceCancellable != nil { return }
        let subviews = NSApp.windows.compactMap { window -> NSStatusBarButton? in
            guard let contentView = window.contentView,
                  let nsView = contentView.subviews.first,
                  let barButton = nsView.subviews.first as? NSStatusBarButton else {
                return nil
            }
            return barButton
        }
        guard let barButton = subviews.first else { return }
        appearanceCancellable = barButton
            .publisher(for: \.effectiveAppearance)
            .merge(with: NSApp.publisher(for: \.effectiveAppearance, options: .new))
            .sink { [weak self] _ in
                self?.isDark = barButton.effectiveAppearance.isDark
            }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class StatusIconModelMock: StatusIconModel {
        @Published var imageInfo = GGImageInfo(DayData.default, .monochrome, .block, .lastYear)
        @Published var isDark: Bool = false

        init(_ userDefaultsRepository: UserDefaultsRepository,
             _ contributionModel: ContributionModel) {}
        init() {}

        func setAppearanceObserver() {}
    }
}

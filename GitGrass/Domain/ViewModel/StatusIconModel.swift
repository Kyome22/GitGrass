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

import AppKit
import SwiftUI
import Combine

protocol StatusIconModel: ObservableObject {
    var imageInfo: GGImageInfo { get set }
    var isDark: Bool { get set }

    init(_ contributionModel: ContributionModel)

    func setAppearanceObserver()
}

final class StatusIconModelImpl: StatusIconModel {
    @Published var imageInfo: GGImageInfo = .default
    @Published var isDark: Bool = false

    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()

    init(_ contributionModel: ContributionModel) {
        contributionModel.imageInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageInfo in
                self?.imageInfo = imageInfo
            }
            .store(in: &cancellables)
    }

    // Workaround for broken colorScheme in MenuBarExtra
    func setAppearanceObserver() {
        guard statusItem == nil else { return }
        statusItem = NSStatusItem.default
        statusItem?.isVisible = false
        guard let barButton = statusItem?.button else { return }
        barButton.publisher(for: \.effectiveAppearance)
            .merge(with: NSApp.publisher(for: \.effectiveAppearance, options: .new))
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.isDark = barButton.effectiveAppearance.isDark
            }
            .store(in: &cancellables)
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class StatusIconModelMock: StatusIconModel {
        @Published var imageInfo: GGImageInfo = .default
        @Published var isDark: Bool = false

        init(_ contributionModel: ContributionModel) {}
        init() {}

        func setAppearanceObserver() {}
    }
}

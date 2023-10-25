/*
 MenuBarModel.swift
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
import Combine

protocol MenuBarModel: ObservableObject {
    var imageInfo: GGImageInfo { get set }

    init(_ userDefaultsRepository: UserDefaultsRepository,
         _ contributionModel: ContributionModel,
         _ windowModel: WindowModel)

    func openSettings()
    func openAbout()
    func openLicenses()
    func terminateApp()
}

final class MenuBarModelImpl<UR: UserDefaultsRepository,
                             CM: ContributionModel,
                             WM: WindowModel>: MenuBarModel {
    private let userDefaultsRepository: UR
    private let contributionModel: CM
    private let windowModel: WM
    private var cancellables = Set<AnyCancellable>()

    @Published var imageInfo = GGImageInfo(DayData.default, .monochrome, .block, .lastYear)

    init(
        _ userDefaultsRepository: UserDefaultsRepository,
        _ contributionModel: ContributionModel,
        _ windowModel: WindowModel
    ) {
        self.userDefaultsRepository = userDefaultsRepository as! UR
        self.contributionModel = contributionModel as! CM
        self.windowModel = windowModel as! WM
        let properties = GGProperties(userDefaultsRepository.color,
                                      userDefaultsRepository.style,
                                      userDefaultsRepository.period)
        userDefaultsRepository.propertiesPublisher
            .prepend(properties)
            .combineLatest(contributionModel.dayDataPublisher)
            .map { ($1, $0.0, $0.1, $0.2) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (dayData, color, style, period) in
                self?.imageInfo = GGImageInfo(dayData, color, style, period)
            }
            .store(in: &cancellables)
    }

    func openSettings() {
        windowModel.openSettings()
    }

    func openAbout() {
        windowModel.openAbout()
    }

    func openLicenses() {
        windowModel.openLicenses()
    }

    func terminateApp() {
        NSApp.terminate(nil)
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class MenuBarModelMock: MenuBarModel {
        @Published var imageInfo = GGImageInfo(DayData.default,
                                               GGColor.monochrome,
                                               GGStyle.block,
                                               GGPeriod.lastYear)

        init(_ userDefaultsRepository: UserDefaultsRepository,
             _ contributionModel: ContributionModel,
             _ windowModel: WindowModel) {}
        init() {}

        func openSettings() {}
        func openAbout() {}
        func openLicenses() {}
        func terminateApp() {}
    }
}

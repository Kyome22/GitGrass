/*
 MenuBarModel.swift
 GitGrass

 Created by Takuto Nakamura on 2023/01/25.
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

protocol MenuBarModel: AnyObject {
    var imageInfoPublisher: AnyPublisher<GGImageInfo, Never> { get }

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
    private let windowModel: WindowModel
    private var cancellables = Set<AnyCancellable>()

    private let imageInfoSubject = PassthroughSubject<GGImageInfo, Never>()
    var imageInfoPublisher: AnyPublisher<GGImageInfo, Never> {
        return imageInfoSubject.eraseToAnyPublisher()
    }

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
        self.userDefaultsRepository.propertiesPublisher
            .prepend(properties)
            .combineLatest(self.contributionModel.dayDataPublisher)
            .map { ($1, $0.0, $0.1, $0.2) }
            .sink { [weak self] (dayData, color, style, period) in
                self?.imageInfoSubject.send(GGImageInfo(dayData, color, style, period))
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
        var imageInfoPublisher: AnyPublisher<GGImageInfo, Never> {
            return Just(GGImageInfo.mock).eraseToAnyPublisher()
        }

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

/*
 GitGrassAppModel.swift
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

// PublishedなPropertyを持っていないので今はObservableObjectである意味がない
protocol GitGrassAppModel: ObservableObject {
    associatedtype UR: UserDefaultsRepository
    associatedtype KR: KeychainRepository
    associatedtype CM: ContributionModel
    associatedtype WM: WindowModel
    associatedtype MVM: MenuViewModel
    associatedtype SIM: StatusIconModel
    associatedtype GVM: GeneralSettingsViewModel

    var userDefaultsRepository: UR { get }
    var keychainRepository: KR { get }
    var contributionModel: CM { get }
    var windowModel: WM { get }
}

final class GitGrassAppModelImpl: NSObject, GitGrassAppModel {
    typealias UR = UserDefaultsRepositoryImpl
    typealias KR = KeychainRepositoryImpl
    typealias CM = ContributionModelImpl<ContributionRepositoryImpl>
    typealias WM = WindowModelImpl
    typealias MVM = MenuViewModelImpl
    typealias SIM = StatusIconModelImpl
    typealias GVM = GeneralSettingsViewModelImpl<LaunchAtLoginRepositoryImpl>

    let userDefaultsRepository: UR
    let keychainRepository: KR
    let contributionModel: CM
    let windowModel: WM
    private var cancellables = Set<AnyCancellable>()

    override init() {
        userDefaultsRepository = UR()
        keychainRepository = KR()
        contributionModel = CM(userDefaultsRepository, keychainRepository)
        windowModel = WM()
        super.init()

        NotificationCenter.default.publisher(for: NSApplication.didFinishLaunchingNotification)
            .sink { [weak self] _ in
                self?.applicationDidFinishLaunching()
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.applicationWillTerminate()
            }
            .store(in: &cancellables)
    }

    private func applicationDidFinishLaunching() {
        contributionModel.fetchGrass()
        if keychainRepository.personalAccessToken == nil || userDefaultsRepository.username.isEmpty {
            windowModel.openSettings()
        }
    }

    private func applicationWillTerminate() {
        contributionModel.stopTimer()
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class GitGrassAppModelMock: GitGrassAppModel {
        typealias UR = UserDefaultsRepositoryMock
        typealias KR = KeychainRepositoryMock
        typealias CM = ContributionModelMock
        typealias WM = WindowModelMock
        typealias MVM = MenuViewModelMock
        typealias SIM = StatusIconModelMock
        typealias GVM = GeneralSettingsViewModelMock

        let userDefaultsRepository = UR()
        let keychainRepository = KR()
        let contributionModel = CM()
        let windowModel = WM()
    }
}

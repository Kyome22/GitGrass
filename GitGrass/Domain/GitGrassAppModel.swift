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
    associatedtype MBM: MenuBarModel

    var userDefaultsRepository: UR { get }
    var keychainRepository: KR { get }
    var menuBarModel: MBM { get }
}

final class GitGrassAppModelImpl: NSObject, GitGrassAppModel {
    typealias UR = UserDefaultsRepositoryImpl
    typealias KR = KeychainRepositoryImpl
    typealias CR = ContributionRepositoryImpl
    typealias CM = ContributionModelImpl<UR, KR, CR>
    typealias WM = WindowModelImpl
    typealias MBM = MenuBarModelImpl<UR, CM, WM>

    let userDefaultsRepository: UR
    let keychainRepository: KR
    private let contributionModel: CM
    private let windowModel: WM
    let menuBarModel: MBM
    private var cancellables = Set<AnyCancellable>()

    override init() {
        userDefaultsRepository = UR()
        keychainRepository = KR()
        contributionModel = CM(userDefaultsRepository, keychainRepository)
        windowModel = WM()
        menuBarModel = MBM(userDefaultsRepository, contributionModel, windowModel)
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
        typealias MBM = MenuBarModelMock

        var userDefaultsRepository = UR()
        var keychainRepository = KR()
        var menuBarModel = MBM()
    }
}

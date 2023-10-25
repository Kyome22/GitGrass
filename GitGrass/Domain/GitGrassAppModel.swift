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

    var userDefaultsRepository: UR { get }
    var keychainRepository: KR { get }
}

final class GitGrassAppModelImpl: NSObject, GitGrassAppModel {
    typealias UR = UserDefaultsRepositoryImpl
    typealias KR = KeychainRepositoryImpl
    typealias CR = ContributionRepositoryImpl
    typealias CMConcrete = ContributionModelImpl<UR, KR, CR>
    typealias WM = WindowModelImpl
    typealias MMConcrete = MenuBarModelImpl<UR, CMConcrete, WM>


    let userDefaultsRepository: UR
    let keychainRepository: KR

    private let contributionModel: CMConcrete
    private let windowModel: WindowModelImpl
    private let menuBarModel: MMConcrete
    private var menuBar: MenuBar<MMConcrete>?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        userDefaultsRepository = UR()
        keychainRepository = KR()
        contributionModel = CMConcrete(userDefaultsRepository, keychainRepository)
        windowModel = WindowModelImpl()
        menuBarModel = MMConcrete(userDefaultsRepository, contributionModel, windowModel)
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
        menuBar = MenuBar(menuBarModel: menuBarModel)
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

        var userDefaultsRepository = UR()
        var keychainRepository = KR()
    }
}

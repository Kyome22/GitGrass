//
//  GitGrassAppModel.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//  Copyright 2023 Takuto Nakamura
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit
import Combine

// PublishedなPropertyを持っていないので今はObservableObjectである意味がない
protocol GitGrassAppModel: ObservableObject {
    associatedtype UR: UserDefaultsRepository
    var userDefaultsRepository: UR { get }
}

final class GitGrassAppModelImpl: NSObject, GitGrassAppModel {
    typealias UR = UserDefaultsRepositoryImpl
    typealias CR = ContributionRepositoryImpl
    typealias CM = ContributionModelImpl
    typealias WM = WindowModelImpl

    let userDefaultsRepository: UR

    private let contributionModel: CM<UR, CR>
    private let windowModel: WindowModelImpl
    private let menuBarModel: MenuBarModelImpl<UR, CM<UR, CR>, WM>
    private var menuBar: MenuBar<MenuBarModelImpl<UR, CM<UR, CR>, WM>>?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        userDefaultsRepository = UR()
        contributionModel = CM<UR, CR>(userDefaultsRepository)
        windowModel = WindowModelImpl()
        menuBarModel = MenuBarModelImpl(userDefaultsRepository, contributionModel, windowModel)
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
        contributionModel.startTimer()
        if userDefaultsRepository.username.isEmpty {
            windowModel.openPreferences()
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
        var userDefaultsRepository = UR()
    }
}

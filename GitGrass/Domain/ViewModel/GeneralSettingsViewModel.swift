/*
  GeneralSettingsViewModel.swift
  GitGrass

  Created by Takuto Nakamura on 2022/10/11.
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

import AppKit

protocol GeneralSettingsViewModel: ObservableObject {
    var personalAccessToken: String { get set }
    var tokenIsAlreadyStored: Bool { get }
    var username: String { get set }
    var cycle: GGCycle { get set }
    var color: GGColor { get set }
    var style: GGStyle { get set }
    var period: GGPeriod { get set }
    var launchAtLogin: Bool { get set }

    init(_ userDefaultsRepository: UserDefaultsRepository,
         _ keychainRepository: KeychainRepository)

    func resetToken()
    func saveToken()
    func updateUsername()
}

final class GeneralSettingsViewModelImpl<UR: UserDefaultsRepository,
                                         KR: KeychainRepository,
                                         LR: LaunchAtLoginRepository>: GeneralSettingsViewModel {
    @Published var personalAccessToken: String = ""
    @Published var tokenIsAlreadyStored: Bool = false
    @Published var username: String
    @Published var cycle: GGCycle {
        didSet { userDefaultsRepository.cycle = cycle }
    }
    @Published var color: GGColor {
        didSet { userDefaultsRepository.color = color }
    }
    @Published var style: GGStyle {
        didSet { userDefaultsRepository.style = style }
    }
    @Published var period: GGPeriod {
        didSet { userDefaultsRepository.period = period }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            launchAtLoginRepository.switchRegistration(launchAtLogin) { [weak self] in
                self?.launchAtLogin = oldValue
            }
        }
    }

    private let userDefaultsRepository: UR
    private let keychainRepository: KR
    private let launchAtLoginRepository: LR

    init(
        _ userDefaultsRepository: UserDefaultsRepository,
        _ keychainRepository: KeychainRepository
    ) {
        self.userDefaultsRepository = userDefaultsRepository as! UR
        self.keychainRepository = keychainRepository as! KR
        self.launchAtLoginRepository = LR()
        username = userDefaultsRepository.username
        cycle = userDefaultsRepository.cycle
        color = userDefaultsRepository.color
        style = userDefaultsRepository.style
        period = userDefaultsRepository.period
        launchAtLogin = launchAtLoginRepository.current
        setToken()
    }

    private func setToken() {
        let token = keychainRepository.personalAccessToken ?? ""
        personalAccessToken = token
        tokenIsAlreadyStored = !token.isEmpty
    }

    func resetToken() {
        Task {
            keychainRepository.personalAccessToken = nil
            Task { @MainActor in
                setToken()
            }
        }
    }

    func saveToken() {
        Task {
            keychainRepository.personalAccessToken = personalAccessToken
            Task { @MainActor in
                setToken()
            }
        }
    }

    func updateUsername() {
        userDefaultsRepository.username = username
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class GeneralSettingsViewModelMock: GeneralSettingsViewModel {
        @Published var personalAccessToken: String = ""
        @Published var tokenIsAlreadyStored: Bool = false
        @Published var username: String = ""
        @Published var cycle: GGCycle = .minutes5
        @Published var color: GGColor = .monochrome
        @Published var style: GGStyle = .block
        @Published var period: GGPeriod = .lastYear
        @Published var launchAtLogin: Bool = true

        init(_ userDefaultsRepository: UserDefaultsRepository,
             _ keychainRepository: KeychainRepository) {}
        init() {}

        func resetToken() {}
        func saveToken() {}
        func updateUsername() {}
    }
}

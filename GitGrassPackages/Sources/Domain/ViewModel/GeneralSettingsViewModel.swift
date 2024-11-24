/*
 GeneralSettingsViewModel.swift
 Domain

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
import Foundation
import Observation

@MainActor @Observable public final class GeneralSettingsViewModel {
    private let keychainRepository: KeychainRepository
    private let launchAtLoginRepository: LaunchAtLoginRepository
    private let userDefaultsRepository: UserDefaultsRepository
    private let contributionService: ContributionService
    private let logService: LogService

    public var personalAccessToken = ""
    public var tokenIsAlreadyStored = false
    public var username: String
    public var cycle: GGCycle
    public var color: GGColor
    public var style: GGStyle
    public var period: GGPeriod
    public var launchAtLoginIsEnabled: Bool

    public init(
        _ keychainClient: KeychainClient,
        _ smAppServiceClient: SMAppServiceClient,
        _ userDefaultsClient: UserDefaultsClient,
        _ contributionService: ContributionService,
        _ logService: LogService
    ) {
        self.keychainRepository = .init(keychainClient)
        self.launchAtLoginRepository = .init(smAppServiceClient)
        self.userDefaultsRepository = .init(userDefaultsClient)
        self.contributionService = contributionService
        self.logService = logService
        username = userDefaultsRepository.username
        cycle = userDefaultsRepository.cycle
        color = userDefaultsRepository.color
        style = userDefaultsRepository.style
        period = userDefaultsRepository.period
        launchAtLoginIsEnabled = launchAtLoginRepository.isEnabled
        setToken()
    }

    public func onAppear(screenName: String) {
        logService.notice(.screenView(name: screenName))
    }

    private func setToken() {
        let token = keychainRepository.personalAccessToken ?? ""
        personalAccessToken = token
        tokenIsAlreadyStored = !token.isEmpty
    }

    public func resetToken() async {
        await Task.detached(priority: .background) {
            self.keychainRepository.personalAccessToken = nil
        }.value
        setToken()
    }

    public func saveToken() async {
        await Task.detached(priority: .background) { [token = personalAccessToken] in
            self.keychainRepository.personalAccessToken = token
        }.value
        setToken()
    }

    public func updateUsername() {
        userDefaultsRepository.username = username
        Task.detached(priority: .background) {
            await self.contributionService.fetchGrass()
        }
    }

    public func updateCycle(_ cycle: GGCycle) {
        userDefaultsRepository.cycle = cycle
        Task {
            await self.contributionService.updateCycle()
        }
    }

    public func updateImageProperties(
        color: GGColor? = nil,
        style: GGStyle? = nil,
        period: GGPeriod? = nil
    ) {
        if let color {
            userDefaultsRepository.color = color
        }
        if let style {
            userDefaultsRepository.style = style
        }
        if let period {
            userDefaultsRepository.period = period
        }
        Task {
            await self.contributionService.updateImageInfo(with: nil)
        }
    }

    public func launchAtLoginSwitched(_ isEnabled: Bool) {
        switch launchAtLoginRepository.switchStatus(isEnabled) {
        case .success:
            launchAtLoginIsEnabled = isEnabled
        case let .failure(.switchFailed(value)):
            launchAtLoginIsEnabled = value
        }
    }
}

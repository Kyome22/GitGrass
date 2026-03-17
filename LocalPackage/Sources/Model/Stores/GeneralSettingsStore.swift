/*
 GeneralSettingsStore.swift
 Model

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

import DataSource
import Observation

@MainActor @Observable
public final class GeneralSettingsStore: Composable {
    private let keychainRepository: KeychainRepository
    private let launchAtLoginRepository: LaunchAtLoginRepository
    private let userDefaultsRepository: UserDefaultsRepository
    private let contributionService: ContributionService
    private let logService: LogService

    public var personalAccessToken: String
    public var tokenIsAlreadyStored: Bool
    public var username: String
    public var cycle: GGCycle
    public var color: GGColor
    public var style: GGStyle
    public var period: GGPeriod
    public var launchAtLoginIsEnabled: Bool
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        personalAccessToken: String = "",
        tokenIsAlreadyStored: Bool = false,
        username: String? = nil,
        cycle: GGCycle? = nil,
        color: GGColor? = nil,
        style: GGStyle? = nil,
        period: GGPeriod? = nil,
        launchAtLoginIsEnabled: Bool? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.keychainRepository = .init(appDependencies.keychainClient)
        self.launchAtLoginRepository = .init(appDependencies.smAppServiceClient)
        self.userDefaultsRepository = .init(appDependencies.userDefaultsClient)
        self.contributionService = .init(appDependencies)
        self.logService = .init(appDependencies)
        self.personalAccessToken = personalAccessToken
        self.tokenIsAlreadyStored = tokenIsAlreadyStored
        self.username = username ?? userDefaultsRepository.username
        self.cycle = cycle ?? userDefaultsRepository.cycle
        self.color = color ?? userDefaultsRepository.color
        self.style = style ?? userDefaultsRepository.style
        self.period = period ?? userDefaultsRepository.period
        self.launchAtLoginIsEnabled = launchAtLoginIsEnabled ?? launchAtLoginRepository.isEnabled
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))
            setToken()

        case .usernameSubmitted:
            userDefaultsRepository.username = username
            await Task.detached(priority: .background) { [contributionService] in
                await contributionService.fetchContributions()
            }.value

        case .updateButtonTapped:
            await Task.detached(priority: .background) { [contributionService] in
                await contributionService.fetchContributions()
            }.value

        case .resetButtonTapped:
            await Task.detached(priority: .background) { [keychainRepository] in
                keychainRepository.personalAccessToken = nil
            }.value
            setToken()

        case .saveButtonTapped:
            await Task.detached(priority: .background) { [keychainRepository, token = personalAccessToken] in
                keychainRepository.personalAccessToken = token
            }.value
            setToken()

        case let .cyclePickerSelected(cycle):
            self.cycle = cycle
            userDefaultsRepository.cycle = cycle
            contributionService.updateCycle()

        case let .colorPickerSelected(color):
            self.color = color
            userDefaultsRepository.color = color
            contributionService.updateImageInfo(with: nil)

        case let .stylePickerSelected(style):
            self.style = style
            userDefaultsRepository.style = style
            contributionService.updateImageInfo(with: nil)

        case let .periodPickerSelected(period):
            self.period = period
            userDefaultsRepository.period = period
            contributionService.updateImageInfo(with: nil)

        case let .launchAtLoginToggleSwitched(isOn):
            switch launchAtLoginRepository.switchStatus(isOn) {
            case .success:
                launchAtLoginIsEnabled = isOn
            case let .failure(.switchFailed(value)):
                launchAtLoginIsEnabled = value
            }
        }
    }

    private func setToken() {
        let token = keychainRepository.personalAccessToken ?? ""
        personalAccessToken = token
        tokenIsAlreadyStored = !token.isEmpty
    }

    public enum Action: Sendable {
        case task(String)
        case usernameSubmitted
        case updateButtonTapped
        case resetButtonTapped
        case saveButtonTapped
        case cyclePickerSelected(GGCycle)
        case colorPickerSelected(GGColor)
        case stylePickerSelected(GGStyle)
        case periodPickerSelected(GGPeriod)
        case launchAtLoginToggleSwitched(Bool)
    }
}

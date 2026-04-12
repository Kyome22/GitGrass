/*
 ContributionService.swift
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
import Foundation

struct ContributionService {
    private let appStateClient: AppStateClient
    private let contributionRepository: ContributionRepository
    private let keychainRepository: KeychainRepository
    private let userDefaultsRepository: UserDefaultsRepository

    init(_ appDependencies: AppDependencies) {
        appStateClient = appDependencies.appStateClient
        contributionRepository = .init(appDependencies.urlSessionClient)
        keychainRepository = .init(appDependencies.keychainClient)
        userDefaultsRepository = .init(appDependencies.userDefaultsClient)
    }

    func initializeSubject() {
        appStateClient.send(\.cycleSubject, input: userDefaultsRepository.cycle)
        let imageProperties = ImageProperties(
            dayData: DayData.emptyYear,
            color: userDefaultsRepository.color,
            style: userDefaultsRepository.style,
            period: userDefaultsRepository.period
        )
        appStateClient.send(\.imagePropertiesSubject, input: imageProperties)
    }

    func stopPolling() {
        appStateClient.withLock {
            $0.pollingTask?.cancel()
            $0.pollingTask = nil
        }
    }

    func startPolling() {
        stopPolling()
        let interval = 60 * Double(userDefaultsRepository.cycle.rawValue)
        let timer = AsyncStream {
            try? await Task.sleep(for: .seconds(interval))
        }
        let task = Task {
            for await _ in timer {
                await fetchContributions()
            }
        }
        appStateClient.withLock { $0.pollingTask = task }
    }

    func updateCycle() {
        appStateClient.send(\.cycleSubject, input: userDefaultsRepository.cycle)
    }

    func updateImageInfo(with dayData: [[DayData]]?) {
        let _dayData = if let dayData {
            dayData
        } else {
            appStateClient.withLock(\.imagePropertiesSubject).value.dayData
        }
        appStateClient.send(\.imagePropertiesSubject, input: .init(
            dayData: _dayData,
            color: userDefaultsRepository.color,
            style: userDefaultsRepository.style,
            period: userDefaultsRepository.period
        ))
    }

    private func convert(user: GitHubUser) -> [[DayData]] {
        let calendar = user.contributionsCollection.contributionCalendar
        return calendar.weeks.map { week in
            week.contributionDays.map { day in
                DayData(
                    level: day.contributionLevel.integer,
                    count: day.contributionCount,
                    date: day.date
                )
            }
        }
    }

    func fetchContributions() async {
        let username = userDefaultsRepository.username
        guard !username.isEmpty, let token = keychainRepository.personalAccessToken else {
            updateImageInfo(with: DayData.emptyYear)
            return
        }
        do {
            let user = try await contributionRepository.fetchContributions(token: token, username: username)
            updateImageInfo(with: convert(user: user))
        } catch {
            appStateClient.send(\.errorSubject, input: .fetchContributionsFailed(error))
            updateImageInfo(with: DayData.emptyYear)
        }
    }
}

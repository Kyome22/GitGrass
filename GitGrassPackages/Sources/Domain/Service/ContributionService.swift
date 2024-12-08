/*
 ContributionService.swift
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

import Combine
import DataLayer
import Foundation

public actor ContributionService {
    private let cycleSubject = PassthroughSubject<Void, Never>()
    private let imagePropertiesSubject: CurrentValueSubject<ImageProperties, Never>
    private let errorSubject = PassthroughSubject<any Error, Never>()
    private let contributionRepository: ContributionRepository
    private let keychainRepository: KeychainRepository
    private let userDefaultsRepository: UserDefaultsRepository

    public init(
        _ keychainClient: KeychainClient,
        _ urlSessionClient: URLSessionClient,
        _ userDefaultsClient: UserDefaultsClient
    ) {
        self.contributionRepository = .init(urlSessionClient)
        self.keychainRepository = .init(keychainClient)
        self.userDefaultsRepository = .init(userDefaultsClient)
        imagePropertiesSubject = .init(.init(
            dayData: DayData.default,
            color: userDefaultsRepository.color,
            style: userDefaultsRepository.style,
            period: userDefaultsRepository.period
        ))
    }

    public func cycleStream() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let cancellable = cycleSubject.sink { value in
                continuation.yield(value)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }

    public func imagePropertiesStream() -> AsyncStream<ImageProperties> {
        AsyncStream { continuation in
            let cancellable = imagePropertiesSubject.sink { value in
                continuation.yield(value)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }

    public func errorStream() -> AsyncStream<any Error> {
        AsyncStream { continuation in
            let cancellable = errorSubject.sink { value in
                continuation.yield(value)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }

    public func updateCycle() {
        cycleSubject.send()
    }

    public func updateImageInfo(with dayData: [[DayData]]?) {
        let _dayData = if let dayData {
            dayData
        } else {
            imagePropertiesSubject.value.dayData
        }
        imagePropertiesSubject.send(.init(
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

    public func fetchGrass() async {
        let username = userDefaultsRepository.username
        guard !username.isEmpty, let token = keychainRepository.personalAccessToken else {
            updateImageInfo(with: DayData.default)
            return
        }
        do {
            let user = try await contributionRepository.getGrass(token: token, username: username)
            updateImageInfo(with: convert(user: user))
        } catch {
            errorSubject.send(error)
            updateImageInfo(with: DayData.default)
        }
    }
}

extension AnyCancellable: @retroactive @unchecked Sendable {}

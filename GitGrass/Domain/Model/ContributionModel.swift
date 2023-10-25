/*
 GitGrassManager.swift
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

protocol ContributionModel: AnyObject {
    var dayDataPublisher: AnyPublisher<[[DayData]], Never> { get }

    init(_ userDefaultsRepository: UserDefaultsRepository,
         _ keychainRepository: KeychainRepository)

    func fetchGrass()
    func stopTimer()
    func updateCycle()
}

final class ContributionModelImpl<UR: UserDefaultsRepository,
                                  KR: KeychainRepository,
                                  CR: ContributionRepository>: ContributionModel {
    private let userDefaultsRepository: UR
    private let keychainRepository: KR
    private let contributionRepository: CR
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private let dayDataSubject = CurrentValueSubject<[[DayData]], Never>(DayData.default)
    var dayDataPublisher: AnyPublisher<[[DayData]], Never> {
        return dayDataSubject.eraseToAnyPublisher()
    }

    init(
        _ userDefaultsRepository: UserDefaultsRepository,
        _ keychainRepository: KeychainRepository
    ) {
        self.userDefaultsRepository = userDefaultsRepository as! UR
        self.keychainRepository = keychainRepository as! KR
        self.contributionRepository = CR()

        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.willSleepNotification)
            .sink { [weak self] _ in
                self?.stopTimer()
            }
            .store(in: &cancellables)
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didWakeNotification)
            .sink { [weak self] _ in
                self?.fetchGrass()
            }
            .store(in: &cancellables)

        self.userDefaultsRepository.usernamePublisher
            .sink { [weak self] _ in
                self?.fetchGrass()
            }
            .store(in: &cancellables)
        self.userDefaultsRepository.cyclePublisher
            .sink { [weak self] _ in
                self?.updateCycle()
            }
            .store(in: &cancellables)
    }

    private func convert(output: ContributionsOutput) -> [[DayData]] {
        let calendar = output.user.contributionsCollection.contributionCalendar
        return calendar.weeks.map { week in
            week.contributionDays.map { day in
                return DayData(day.contributionLevel.integer, day.contributionCount, day.date)
            }
        }
    }

    func fetchGrass() {
        let username = userDefaultsRepository.username
        guard !username.isEmpty, let token = keychainRepository.personalAccessToken else {
            dayDataSubject.send(DayData.default)
            return
        }
        Task {
            do {
                let output = try await contributionRepository.getGrass(token, username)
                dayDataSubject.send(convert(output: output))
                startTimer()
            } catch {
                dayDataSubject.send(DayData.default)
            }
        }
    }

    private func startTimer() {
        let interval = 60.0 * Double(userDefaultsRepository.cycle.rawValue)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.fetchGrass()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateCycle() {
        stopTimer()
        startTimer()
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ContributionModelMock: ContributionModel {
        var dayDataPublisher: AnyPublisher<[[DayData]], Never> {
            return Just(DayData.default).eraseToAnyPublisher()
        }

        init(_ userDefaultsRepository: UserDefaultsRepository,
             _ keychainRepository: KeychainRepository) {}
        init() {}

        func fetchGrass() {}
        func stopTimer() {}
        func updateCycle() {}
    }
}

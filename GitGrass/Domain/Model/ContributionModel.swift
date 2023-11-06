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
    var imageInfoPublisher: AnyPublisher<GGImageInfo, Never> { get }

    init(_ userDefaultsRepository: UserDefaultsRepository,
         _ keychainRepository: KeychainRepository)

    func fetchGrass()
    func stopTimer()
}

final class ContributionModelImpl<CR: ContributionRepository>: ContributionModel {
    private let userDefaultsRepository: UserDefaultsRepository
    private let keychainRepository: KeychainRepository
    private let contributionRepository: CR
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private let imageInfoSubject: CurrentValueSubject<GGImageInfo, Never>
    var imageInfoPublisher: AnyPublisher<GGImageInfo, Never> {
        return imageInfoSubject.eraseToAnyPublisher()
    }

    init(
        _ userDefaultsRepository: UserDefaultsRepository,
        _ keychainRepository: KeychainRepository
    ) {
        self.userDefaultsRepository = userDefaultsRepository
        self.keychainRepository = keychainRepository
        self.contributionRepository = CR()

        imageInfoSubject = .init(GGImageInfo(
            dayData: DayData.default,
            color: userDefaultsRepository.color,
            style: userDefaultsRepository.style,
            period: userDefaultsRepository.period
        ))

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

        userDefaultsRepository.usernamePublisher
            .sink { [weak self] _ in
                self?.fetchGrass()
            }
            .store(in: &cancellables)
        userDefaultsRepository.cyclePublisher
            .sink { [weak self] _ in
                self?.startTimer()
            }
            .store(in: &cancellables)
        userDefaultsRepository.propertiesPublisher
            .sink { [weak self] in
                self?.updateImageInfo()
            }
            .store(in: &cancellables)
    }

    private func updateImageInfo(with dayData: [[DayData]]? = nil) {
        if let dayData {
            imageInfoSubject.send(GGImageInfo(
                dayData: dayData,
                color: userDefaultsRepository.color,
                style: userDefaultsRepository.style,
                period: userDefaultsRepository.period
            ))
        } else {
            let dayData = imageInfoSubject.value.dayData
            imageInfoSubject.send(GGImageInfo(
                dayData: dayData,
                color: userDefaultsRepository.color,
                style: userDefaultsRepository.style,
                period: userDefaultsRepository.period
            ))
        }
        startTimer()
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
            updateImageInfo(with: DayData.default)
            return
        }
        Task {
            do {
                let output = try await contributionRepository.getGrass(token, username)
                updateImageInfo(with: convert(output: output))
            } catch {
                logput(error.localizedDescription)
                updateImageInfo(with: DayData.default)
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = nil
        let interval = 60.0 * Double(userDefaultsRepository.cycle.rawValue)
        let date = Date.now.addingTimeInterval(interval)
        timer = Timer(fire: date, interval: 0, repeats: false) { [weak self] _ in
            self?.fetchGrass()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ContributionModelMock: ContributionModel {
        var imageInfoPublisher: AnyPublisher<GGImageInfo, Never> {
            return Just(GGImageInfo.default).eraseToAnyPublisher()
        }

        init(_ userDefaultsRepository: UserDefaultsRepository,
             _ keychainRepository: KeychainRepository) {}
        init() {}

        func fetchGrass() {}
        func stopTimer() {}
    }
}

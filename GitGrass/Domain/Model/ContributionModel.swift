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

    init(_ userDefaultsRepository: UserDefaultsRepository)

    func fetchGrass()
    func startTimer()
    func stopTimer()
    func updateCycle()
}

final class ContributionModelImpl<UR: UserDefaultsRepository,
                                  CR: ContributionRepository>: ContributionModel {
    private let userDefaultsRepository: UR
    private let contributionRepository: CR
    private var timerCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    private let dayDataSubject = CurrentValueSubject<[[DayData]], Never>(DayData.default)
    var dayDataPublisher: AnyPublisher<[[DayData]], Never> {
        return dayDataSubject.eraseToAnyPublisher()
    }

    init(_ userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository as! UR
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
                self?.startTimer()
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

    private func parse(html: String) -> [[DayData]] {
        let tags = html.components(separatedBy: .newlines)
        let rects = tags.compactMap({ (str) -> String? in
            let res = str.trimmingCharacters(in: .whitespaces)
            if res.contains("<rect"), res.contains("data-date="), res.contains("data-level=") {
                let array = res.match(#"(<rect [^>]*?>)"#)
                guard array.count == 2 else { return nil }
                let range = array[1].range(of: array[1])
                return array[1].replacingOccurrences(of: #"<rect|"|>|/>"#,
                                                     with: "",
                                                     options: .regularExpression,
                                                     range: range)
            }
            return nil
        })
        // tidy the day data
        var dayData = [[DayData]](repeating: [], count: 7)
        for i in (0 ..< rects.count) {
            let params = rects[i]
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: " ")
                .map({ (str) -> (key: String, value: String) in
                    let array = str.components(separatedBy: "=")
                    return (array[0], array[1])
                })
            var dict = [String : String]()
            params.forEach { (param) in
                dict[param.key] = param.value
            }
            let level = Int(dict["data-level"] ?? "0") ?? 0
            let count = Int(dict["data-count"] ?? "0") ?? 0
            let date = dict["data-date"] ?? ""
            dayData[i % 7].append(DayData(level, count, date))
        }
        return dayData
    }

    func fetchGrass() {
        let username = userDefaultsRepository.username
        if username.isEmpty {
            dayDataSubject.send(DayData.default)
            return
        }
        Task {
            do {
                let html = try await contributionRepository.getGrass(username: username)
                dayDataSubject.send(parse(html: html))
            } catch {
                dayDataSubject.send(DayData.default)
            }
        }
    }

    func startTimer() {
        let interval = 60.0 * Double(userDefaultsRepository.cycle.rawValue)
        timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .sink { [weak self] _ in
                self?.fetchGrass()
            }
    }

    func stopTimer() {
        timerCancellable?.cancel()
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

        init(_ userDefaultsRepository: UserDefaultsRepository) {}
        init() {}

        func fetchGrass() {}
        func startTimer() {}
        func stopTimer() {}
        func updateCycle() {}
    }
}

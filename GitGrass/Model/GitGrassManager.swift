//
//  GitGrassManager.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import Foundation
import Combine

protocol GitGrassManager: AnyObject {
    var dayDataPublisher: AnyPublisher<[[DayData]], Never> { get }
    var currentDayData: [[DayData]] { get }

    func fetchGrass(username: String)
    func startTimer(username: String, cycle: GGCycle)
    func stopTimer()
    func updateCycle(username: String, cycle: GGCycle)
}

final class GitGrassManagerImpl: GitGrassManager {
    private let dayDataSubject = CurrentValueSubject<[[DayData]], Never>(DayData.default)
    var dayDataPublisher: AnyPublisher<[[DayData]], Never> {
        return dayDataSubject.eraseToAnyPublisher()
    }
    var currentDayData: [[DayData]] {
        return dayDataSubject.value
    }
    private var timerCancellable: AnyCancellable?

    init() {}

    private func getGrass(username: String) async throws -> String {
        let urlString = "https://github.com/users/\(username)/contributions"
        guard let url = URL(string: urlString) else {
            throw GitGrassError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitGrassError.responseError
        }
        if httpResponse.statusCode == 200, let text = String(data: data, encoding: .utf8) {
            return text
        }
        throw GitGrassError.badStatus
    }

    private func getDummyGrass(username: String) async throws -> String {
        if let url = Bundle.main.url(forResource: "dummy", withExtension: "html") {
            return try String(contentsOf: url, encoding: .utf8)
        }
        throw GitGrassError.invalidURL
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

    func fetchGrass(username: String) {
        if username.isEmpty {
            dayDataSubject.send(DayData.default)
            return
        }
        Task {
            do {
                let html = try await getGrass(username: username)
                dayDataSubject.send(parse(html: html))
            } catch {
                dayDataSubject.send(DayData.default)
            }
        }
    }

    func startTimer(username: String, cycle: GGCycle) {
        let interval = 60.0 * Double(cycle.rawValue)
        timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .sink { [weak self] _ in
                self?.fetchGrass(username: username)
            }
    }

    func stopTimer() {
        timerCancellable?.cancel()
    }

    func updateCycle(username: String, cycle: GGCycle) {
        stopTimer()
        startTimer(username: username, cycle: cycle)
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class GitGrassManagerMock: GitGrassManager {
        var dayDataPublisher: AnyPublisher<[[DayData]], Never> {
            return Just(DayData.default).eraseToAnyPublisher()
        }
        var currentDayData: [[DayData]] { [] }

        func fetchGrass(username: String) {}
        func startTimer(username: String, cycle: GGCycle) {}
        func stopTimer() {}
        func updateCycle(username: String, cycle: GGCycle) {}
    }
}

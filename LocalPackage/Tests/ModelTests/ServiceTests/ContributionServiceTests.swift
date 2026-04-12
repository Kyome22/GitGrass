import Foundation
import os
import Testing

@testable import DataSource
@testable import Model

struct ContributionServiceTests {
    @Test
    func initializeSubject_set_userDefaults_values() {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let sut = ContributionService(.testDependencies(
            appStateClient: .testDependency(appState),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.integer = { key in
                    switch key {
                    case "cycle": 15
                    case "color": 1
                    case "style": 1
                    case "period": 2
                    default: 0
                    }
                }
            }
        ))
        sut.initializeSubject()
        #expect(appState.withLock(\.cycleSubject.value) == .minutes15)
        #expect(appState.withLock(\.imagePropertiesSubject.value) == .init(
            dayData: DayData.emptyYear,
            color: .greenGrass,
            style: .dot,
            period: .lastWeek
        ))
    }

    @Test
    func stopPolling() {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        appState.withLock {
            $0.pollingTask = Task {
                try? await Task.sleep(for: .seconds(5))
            }
        }
        let sut = ContributionService(.testDependencies(
            appStateClient: .testDependency(appState)
        ))
        sut.stopPolling()
        #expect(appState.withLock(\.pollingTask) == nil)
    }

    @Test
    func startPolling() {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let sut = ContributionService(.testDependencies(
            appStateClient: .testDependency(appState),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.integer = { key in
                    key == "cycle" ? 5 : 0
                }
            }
        ))
        sut.startPolling()
        #expect(appState.withLock(\.pollingTask)?.isCancelled == false)
        appState.withLock {
            $0.pollingTask?.cancel()
            $0.pollingTask = nil
        }
    }

    @Test
    func updateCycle() {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let cycle = OSAllocatedUnfairLock<GGCycle>(initialState: .minutes5)
        let sut = ContributionService(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.cycleSubject, let value as GGCycle):
                    cycle.withLock { $0 = value }
                default:
                    break
                }
            })),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.integer = { key in
                    key == "cycle" ? 15 : 0
                }
            }
        ))
        sut.updateCycle()
        #expect(appState.withLock(\.cycleSubject.value) == .minutes15)
    }

    @Test(arguments: [
        .init(
            input: nil,
            expect: .init(dayData: DayData.emptyYear, color: .greenGrass, style: .dot, period: .lastMonth)
        ),
        .init(
            input: DayData.mockYear,
            expect: .init(dayData: DayData.mockYear, color: .greenGrass, style: .dot, period: .lastMonth)
        ),
    ] as [ImageInfoProperty])
    func updateImageInfo(_ property: ImageInfoProperty) {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let imageProperties = OSAllocatedUnfairLock<ImageProperties>(initialState: .default)
        let sut = ContributionService(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.imagePropertiesSubject, let value as ImageProperties):
                    imageProperties.withLock { $0 = value }
                default:
                    break
                }
            })),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.integer = { key in
                    switch key {
                    case "color": 1
                    case "style": 1
                    case "period": 1
                    default: 0
                    }
                }
            }
        ))
        sut.updateImageInfo(with: property.input)
        #expect(imageProperties.withLock(\.self) == property.expect)
    }

    @Test(arguments: [
        .init(
            username: nil,
            token: nil,
            statusCode: 400,
            expectImageProperties: .default,
            expectError: nil
        ),
        .init(
            username: "dummy",
            token: nil,
            statusCode: 400,
            expectImageProperties: .default,
            expectError: nil
        ),
        .init(
            username: "dummyUser",
            token: "dummyToken",
            statusCode: 400,
            expectImageProperties: .default,
            expectError: .fetchContributionsFailed(ContributionRepository.OperationError.invalidResponse)
        ),
        .init(
            username: "dummyUser",
            token: "dummyToken",
            statusCode: 200,
            expectImageProperties: .init(dayData: [], color: .monochrome, style: .block, period: .lastYear),
            expectError: nil
        ),
    ] as [ContributionsProperty])
    func fetchContributions(_ property: ContributionsProperty) async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let imageProperties = OSAllocatedUnfairLock<ImageProperties>(initialState: .default)
        let error = OSAllocatedUnfairLock<GGError?>(initialState: nil)
        let sut = ContributionService(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.imagePropertiesSubject, let value as ImageProperties):
                    imageProperties.withLock { $0 = value }
                case (\AppState.errorSubject, let value as GGError):
                    error.withLock { $0 = value }
                default:
                    break
                }
            })),
            keychainClient: testDependency(of: KeychainClient.self) {
                $0.getString = { key in
                    switch key {
                    case "personalAccessToken": property.token
                    default: nil
                    }
                }
            },
            urlSessionClient: testDependency(of: URLSessionClient.self) {
                $0.data = { request in
                    let data = try! JSONEncoder().encode(GraphQLResult(
                        user: .init(
                            contributionsCollection: .init(
                                contributionCalendar: .init(
                                    totalContributions: 0,
                                    weeks: []
                                )
                            )
                        )
                    ))
                    let response = HTTPURLResponse(
                        url: request.url!,
                        statusCode: property.statusCode,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                    return (data, response)
                }
            },
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.integer = { _ in 0 }
                $0.string = { key in
                    switch key {
                    case "username": property.username
                    default: nil
                    }
                }
            }
        ))
        await sut.fetchContributions()
        #expect(imageProperties.withLock(\.self) == property.expectImageProperties)
        #expect(error.withLock(\.self) == property.expectError)
    }
}

struct ImageInfoProperty {
    var input: [[DayData]]?
    var expect: ImageProperties
}

struct ContributionsProperty {
    var username: String?
    var token: String?
    var statusCode: Int
    var expectImageProperties: ImageProperties
    var expectError: GGError?
}

extension DayData {
    private static let mockDay = DayData(level: 1, count: 1, date: "")
    private static let mockWeek = [DayData](repeating: DayData.mockDay, count: 7)
    static let mockYear = [[DayData]](repeating: DayData.mockWeek, count: 53)
}

extension GraphQLResult {
    static let mockEmpty = GraphQLResult(
        user: .init(
            contributionsCollection: .init(
                contributionCalendar: .init(
                    totalContributions: 0,
                    weeks: []
                )
            )
        )
    )
}

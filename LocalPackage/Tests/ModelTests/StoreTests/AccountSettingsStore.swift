import Foundation
import os
import Testing

@testable import DataSource
@testable import Model

struct AccountSettingsStoreTests {
    @MainActor @Test
    func task() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let sut = AccountSettingsStore(.testDependencies(
            appStateClient: .testDependency(appState),
            keychainClient: testDependency(of: KeychainClient.self) {
                $0.getString = { key in
                    if key == "personalAccessToken" {
                        "dummy-token"
                    } else {
                        nil
                    }
                }
            }
        ))
        await sut.send(.task(""))
        #expect(sut.personalAccessToken == "dummy-token")
        #expect(sut.tokenIsAlreadyStored)
    }

    @MainActor @Test
    func usernameSubmitted() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let username = OSAllocatedUnfairLock(initialState: "dummy1")
        let sut = AccountSettingsStore(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.imagePropertiesSubject, _ as ImageProperties):
                    callStack.withLock { $0.append("imagePropertiesSubject") }
                default:
                    break
                }
            })),
            keychainClient: testDependency(of: KeychainClient.self) {
                $0.getString = { key in
                    if key == "personalAccessToken" {
                        "dummy-token"
                    } else {
                        nil
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
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                    return (data, response)
                }
            },
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.string = { key in
                    if key == "username" {
                        username.withLock(\.self)
                    } else {
                        nil
                    }
                }
                $0.setString = { value, key in
                    if key == "username" {
                        username.withLock { $0 = value }
                    }
                }
            }
        ))
        sut.username = "dummy2"
        await sut.send(.usernameSubmitted)
        #expect(username.withLock(\.self) == "dummy2")
        #expect(callStack.withLock(\.self) == ["imagePropertiesSubject"])
    }

    @MainActor @Test
    func updateButtonTapped() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = AccountSettingsStore(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.imagePropertiesSubject, _ as ImageProperties):
                    callStack.withLock { $0.append("imagePropertiesSubject") }
                default:
                    break
                }
            })),
            keychainClient: testDependency(of: KeychainClient.self) {
                $0.getString = { key in
                    if key == "personalAccessToken" {
                        "dummy-token"
                    } else {
                        nil
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
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                    return (data, response)
                }
            },
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.string = { key in
                    key == "username" ? "dummy" : nil
                }
            }
        ))
        await sut.send(.updateButtonTapped)
        #expect(callStack.withLock(\.self) == ["imagePropertiesSubject"])
    }

    @MainActor @Test
    func resetButtonTapped() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let personalAccessToken = OSAllocatedUnfairLock<String?>(initialState: "dummy-token")
        let sut = AccountSettingsStore(.testDependencies(
            appStateClient: .testDependency(appState),
            keychainClient: testDependency(of: KeychainClient.self) {
                $0.getString = { key in
                    if key == "personalAccessToken" {
                        personalAccessToken.withLock(\.self)
                    } else {
                        nil
                    }
                }
                $0.remove = { key in
                    if key == "personalAccessToken" {
                        personalAccessToken.withLock { $0 = nil }
                    }
                }
            }
        ))
        await sut.send(.resetButtonTapped)
        #expect(sut.personalAccessToken == "")
        #expect(sut.tokenIsAlreadyStored == false)
    }

    @MainActor @Test
    func saveButtonTapped() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let personalAccessToken = OSAllocatedUnfairLock<String?>(initialState: nil)
        let sut = AccountSettingsStore(.testDependencies(
            appStateClient: .testDependency(appState),
            keychainClient: testDependency(of: KeychainClient.self) {
                $0.getString = { key in
                    if key == "personalAccessToken" {
                        personalAccessToken.withLock(\.self)
                    } else {
                        nil
                    }
                }
                $0.set = { value, key in
                    if key == "personalAccessToken" {
                        personalAccessToken.withLock { $0 = value }
                    }
                }
            }
        ))
        sut.personalAccessToken = "dummy-token"
        await sut.send(.saveButtonTapped)
        #expect(sut.personalAccessToken == "dummy-token")
        #expect(sut.tokenIsAlreadyStored)
    }
}

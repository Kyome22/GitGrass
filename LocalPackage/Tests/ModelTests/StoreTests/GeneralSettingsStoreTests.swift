import os
import ServiceManagement
import Testing

@testable import DataSource
@testable import Model

struct GeneralSettingsStoreTests {
    @MainActor @Test
    func cyclePickerSelected() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = GeneralSettingsStore(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.cycleSubject, let value as GGCycle):
                    callStack.withLock { $0.append("cycleSubject: \(value)") }
                default:
                    break
                }
            })),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.setInteger = { value, key in
                    callStack.withLock { $0.append("setInteger: \(key)-\(value)") }
                }
            }
        ))
        await sut.send(.cyclePickerSelected(.minutes10))
        #expect(callStack.withLock(\.self) == [
            "setInteger: cycle-10",
            "cycleSubject: minutes5",
        ])
    }

    @MainActor @Test
    func colorPickerSelected() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = GeneralSettingsStore(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.imagePropertiesSubject, _ as ImageProperties):
                    callStack.withLock { $0.append("imagePropertiesSubject") }
                default:
                    break
                }
            })),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.setInteger = { value, key in
                    callStack.withLock { $0.append("setInteger: \(key)-\(value)") }
                }
            }
        ))
        await sut.send(.colorPickerSelected(.greenGrass))
        #expect(callStack.withLock(\.self) == [
            "setInteger: color-1",
            "imagePropertiesSubject",
        ])
    }

    @MainActor @Test
    func stylePickerSelected() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = GeneralSettingsStore(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.imagePropertiesSubject, _ as ImageProperties):
                    callStack.withLock { $0.append("imagePropertiesSubject") }
                default:
                    break
                }
            })),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.setInteger = { value, key in
                    callStack.withLock { $0.append("setInteger: \(key)-\(value)") }
                }
            }
        ))
        await sut.send(.stylePickerSelected(.dot))
        #expect(callStack.withLock(\.self) == [
            "setInteger: style-1",
            "imagePropertiesSubject",
        ])
    }

    @MainActor @Test
    func periodPickerSelected() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = GeneralSettingsStore(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.imagePropertiesSubject, _ as ImageProperties):
                    callStack.withLock { $0.append("imagePropertiesSubject") }
                default:
                    break
                }
            })),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.setInteger = { value, key in
                    callStack.withLock { $0.append("setInteger: \(key)-\(value)") }
                }
            }
        ))
        await sut.send(.periodPickerSelected(.lastMonth))
        #expect(callStack.withLock(\.self) == [
            "setInteger: period-1",
            "imagePropertiesSubject",
        ])
    }

    @MainActor @Test
    func launchAtLoginToggleSwitched_success() async {
        let sut = GeneralSettingsStore(
            .testDependencies(
                smAppServiceClient: testDependency(of: SMAppServiceClient.self) {
                    $0.status = { .enabled }
                    $0.register = { /* No Error Thrown */ }
                }
            ),
            launchAtLoginIsEnabled: false
        )
        await sut.send(.launchAtLoginToggleSwitched(true))
        #expect(sut.launchAtLoginIsEnabled == true)
    }

    @MainActor @Test
    func launchAtLoginToggleSwitched_failure() async {
        let sut = GeneralSettingsStore(
            .testDependencies(
                smAppServiceClient: testDependency(of: SMAppServiceClient.self) {
                    $0.status = { .notRegistered }
                    $0.register = {
                        throw NSError(
                            domain: SMAppServiceErrorDomain,
                            code: kSMErrorAuthorizationFailure
                        )
                    }
                }
            ),
            launchAtLoginIsEnabled: false
        )
        await sut.send(.launchAtLoginToggleSwitched(true))
        #expect(sut.launchAtLoginIsEnabled == false)
    }
}

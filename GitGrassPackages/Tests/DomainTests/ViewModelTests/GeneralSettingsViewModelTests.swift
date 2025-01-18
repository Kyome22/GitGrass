import Foundation
import os
import ServiceManagement
import XCTest

@testable import DataLayer
@testable import Domain

final class GeneralSettingsViewModelTests: XCTestCase {
    @MainActor
    func test_launchAtLoginSwitched_有効の要求_成功した_有効に変更される() async {
        let currentStatus = OSAllocatedUnfairLock(initialState: SMAppService.Status.notRegistered)
        let smAppServiceClient = testDependency(of: SMAppServiceClient.self) {
            $0.status = { currentStatus.withLock(\.self) }
            $0.register = { currentStatus.withLock { $0 = .enabled } }
        }
        let userDefaultsClient = testDependency(of: UserDefaultsClient.self) {
            $0.string = { _ in "" }
            $0.integer = { key in key == "cycle" ? 5 : 0 }
        }
        let sut = GeneralSettingsViewModel(
            .testValue,
            smAppServiceClient,
            userDefaultsClient,
            .init(.testValue, .testValue, .testValue),
            .init(.testValue)
        )
        sut.launchAtLoginSwitched(true)
        XCTAssertTrue(sut.launchAtLoginIsEnabled)
    }

    @MainActor
    func test_launchAtLoginSwitched_有効の要求_失敗した_無効に戻される() async {
        let smAppServiceClient = testDependency(of: SMAppServiceClient.self) {
            $0.status = { .notRegistered }
            $0.register = { throw NSError(domain: "", code: kSMErrorInternalFailure) }
        }
        let userDefaultsClient = testDependency(of: UserDefaultsClient.self) {
            $0.string = { _ in "" }
            $0.integer = { key in key == "cycle" ? 5 : 0 }
        }
        let sut = GeneralSettingsViewModel(
            .testValue,
            smAppServiceClient,
            userDefaultsClient,
            .init(.testValue, .testValue, .testValue),
            .init(.testValue)
        )
        sut.launchAtLoginSwitched(true)
        XCTAssertFalse(sut.launchAtLoginIsEnabled)
    }

    @MainActor
    func test_launchAtLoginSwitched_無効の要求_成功した_無効に変更される() async {
        let currentStatus = OSAllocatedUnfairLock(initialState: SMAppService.Status.enabled)
        let smAppServiceClient = testDependency(of: SMAppServiceClient.self) {
            $0.status = { currentStatus.withLock(\.self) }
            $0.unregister = { currentStatus.withLock { $0 = .notRegistered } }
        }
        let userDefaultsClient = testDependency(of: UserDefaultsClient.self) {
            $0.string = { _ in "" }
            $0.integer = { key in key == "cycle" ? 5 : 0 }
        }
        let sut = GeneralSettingsViewModel(
            .testValue,
            smAppServiceClient,
            userDefaultsClient,
            .init(.testValue, .testValue, .testValue),
            .init(.testValue)
        )
        sut.launchAtLoginSwitched(false)
        XCTAssertFalse(sut.launchAtLoginIsEnabled)
    }

    @MainActor
    func test_launchAtLoginSwitched_無効の要求_失敗した_有効に戻される() async {
        let smAppServiceClient = testDependency(of: SMAppServiceClient.self) {
            $0.status = { .enabled }
            $0.unregister = { throw NSError(domain: "", code: kSMErrorInternalFailure) }
        }
        let userDefaultsClient = testDependency(of: UserDefaultsClient.self) {
            $0.string = { _ in "" }
            $0.integer = { key in key == "cycle" ? 5 : 0 }
        }
        let sut = GeneralSettingsViewModel(
            .testValue,
            smAppServiceClient,
            userDefaultsClient,
            .init(.testValue, .testValue, .testValue),
            .init(.testValue)
        )
        sut.launchAtLoginSwitched(false)
        XCTAssertTrue(sut.launchAtLoginIsEnabled)
    }
}

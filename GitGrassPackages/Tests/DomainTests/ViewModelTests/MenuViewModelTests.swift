import Foundation
import os
import XCTest

@testable import DataLayer
@testable import Domain

final class MenuViewModelTests: XCTestCase {
    @MainActor
    func test_activateApp() {
        let count = OSAllocatedUnfairLock(initialState: 0)
        let nsAppClient = testDependency(of: NSAppClient.self) {
            $0.activate = { _ in count.withLock { $0 += 1 } }
        }
        let sut = MenuViewModel(.testValue, nsAppClient, .init(.testValue))
        sut.activateApp()
        XCTAssertEqual(count.withLock(\.self), 1)
    }

    @MainActor
    func test_openAbout() {
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let nsAppClient = testDependency(of: NSAppClient.self) {
            $0.activate = { _ in callStack.withLock { $0.append("activate") } }
            $0.orderFrontStandardAboutPanel = { _ in
                callStack.withLock { $0.append("orderFrontStandardAboutPanel") }
            }
        }
        let sut = MenuViewModel(.testValue, nsAppClient, .init(.testValue))
        sut.openAbout(with: [:])
        XCTAssertEqual(callStack.withLock(\.self), [
            "activate",
            "orderFrontStandardAboutPanel",
        ])
    }

    @MainActor
    func test_openLicenses() {
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let dependencyListClient = testDependency(of: DependencyListClient.self) {
            $0.window = {
                NSWindowMock(call: { value in
                    callStack.withLock { $0.append(value) }
                })
            }
        }
        let nsAppClient = testDependency(of: NSAppClient.self) {
            $0.activate = { _ in callStack.withLock { $0.append("activate") } }
        }
        let sut = MenuViewModel(dependencyListClient, nsAppClient, .init(.testValue))
        sut.openLicenses()
        XCTAssertEqual(callStack.withLock(\.self), [
            "activate",
            "isReleasedWhenClosed false",
            "delegate",
            "center",
            "orderFrontRegardless",
        ])
        callStack.withLock { $0.removeAll() }
        sut.openLicenses()
        XCTAssertEqual(callStack.withLock(\.self), [
            "activate",
            "orderFrontRegardless",
        ])
    }

    @MainActor
    func test_terminateApp() {
        let count = OSAllocatedUnfairLock(initialState: 0)
        let nsAppClient = testDependency(of: NSAppClient.self) {
            $0.terminate = { _ in count.withLock { $0 += 1 } }
        }
        let sut = MenuViewModel(.testValue, nsAppClient, .init(.testValue))
        sut.terminateApp()
        XCTAssertEqual(count.withLock(\.self), 1)
    }
}

final class NSWindowMock: NSWindow {
    let call: (String) -> Void

    override var isReleasedWhenClosed: Bool {
        didSet { call("isReleasedWhenClosed \(isReleasedWhenClosed)")  }
    }

    override var delegate: (any NSWindowDelegate)? {
        didSet { call("delegate") }
    }

    init(call: @escaping (String) -> Void) {
        self.call = call
        super.init(contentRect: .zero, styleMask: [], backing: .buffered, defer: false)
    }

    override func center() {
        call("center")
    }

    override func orderFrontRegardless() {
        call("orderFrontRegardless")
    }
}

import AppKit
import os
import Testing

@testable import DataSource
@testable import Model

struct MenuStoreTests {
    @MainActor @Test
    func settingsLinkTapped() async {
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = MenuStore(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.activate = { value in
                    callStack.withLock { $0.append("activate: \(value)") }
                }
            }
        ))
        await sut.send(.settingsLinkTapped)
        #expect(callStack.withLock(\.self) == ["activate: true"])
    }

    @MainActor @Test
    func aboutButtonTapped() async {
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = MenuStore(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.activate = { value in
                    callStack.withLock { $0.append("activate: \(value)") }
                }
                $0.orderFrontStandardAboutPanel = { _ in
                    callStack.withLock { $0.append("orderFrontStandardAboutPanel") }
                }
            }
        ))
        await sut.send(.aboutButtonTapped(""))
        #expect(callStack.withLock(\.self) == [
            "activate: true",
            "orderFrontStandardAboutPanel",
        ])
    }

    @MainActor @Test
    func licensesButtonTapped_when_licensesWindow_is_nil() async {
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = MenuStore(.testDependencies(
            dependencyListClient: testDependency(of: DependencyListClient.self) {
                $0.window = {
                    NSWindowMock(call: { value in
                        callStack.withLock { $0.append(value) }
                    })
                }
            },
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.activate = { value in
                    callStack.withLock { $0.append("activate: \(value)") }
                }
            }
        ))
        await sut.send(.licensesButtonTapped)
        #expect(callStack.withLock(\.self) == [
            "activate: true",
            "isReleasedWhenClosed false",
            "delegate",
            "center",
            "orderFrontRegardless",
        ])
    }

    @MainActor @Test
    func licensesButtonTapped_when_licensesWindow_is_not_nil() async {
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = MenuStore(
            .testDependencies(
                nsAppClient: testDependency(of: NSAppClient.self) {
                    $0.activate = { value in
                        callStack.withLock { $0.append("activate: \(value)") }
                    }
                }
            ),
            licensesWindow: NSWindowMock(call: { value in
                callStack.withLock { $0.append(value) }
            })
        )
        await sut.send(.licensesButtonTapped)
        #expect(callStack.withLock(\.self) == [
            "activate: true",
            "orderFrontRegardless",
        ])
    }

    @MainActor @Test
    func quitButtonTapped() async {
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = MenuStore(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.terminate = { _ in
                    callStack.withLock { $0.append("terminate") }
                }
            }
        ))
        await sut.send(.quitButtonTapped)
        #expect(callStack.withLock(\.self) == ["terminate"])
    }

    @MainActor @Test
    func debugSleepButtonTapped() async {
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = MenuStore(.testDependencies(
            nsWorkspaceClient: testDependency(of: NSWorkspaceClient.self) {
                $0.post = { notification, _ in
                    callStack.withLock { $0.append("post: \(notification.rawValue)") }
                }
            }
        ))
        await sut.send(.debugSleepButtonTapped)
        #expect(callStack.withLock(\.self) == ["post: NSWorkspaceWillSleepNotification"])
    }

    @MainActor @Test
    func debugWakeUpButtonTapped() async {
        let callStack = OSAllocatedUnfairLock(initialState: [String]())
        let sut = MenuStore(.testDependencies(
            nsWorkspaceClient: testDependency(of: NSWorkspaceClient.self) {
                $0.post = { notification, _ in
                    callStack.withLock { $0.append("post: \(notification.rawValue)") }
                }
            }
        ))
        await sut.send(.debugWakeUpButtonTapped)
        #expect(callStack.withLock(\.self) == ["post: NSWorkspaceDidWakeNotification"])
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

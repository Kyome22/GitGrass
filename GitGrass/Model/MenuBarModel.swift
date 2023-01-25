//
//  MenuBarModel.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import AppKit
import Combine

protocol MenuBarModel: AnyObject {
    var openWindowPublisher: AnyPublisher<WindowType, Never> { get }
    var updateAppearancePublisher: AnyPublisher<Void, Never> { get }
    var updateImageHandler: (([[DayData]], GGColor, GGStyle, GGPeriod) -> Void)? { get set }

    func openPreferences()
    func openAbout()
    func terminateApp()
    func updateAppearance()
}

final class MenuBarModelImpl: MenuBarModel {
    private let openWindowSubject = PassthroughSubject<WindowType, Never>()
    var openWindowPublisher: AnyPublisher<WindowType, Never> {
        return openWindowSubject.eraseToAnyPublisher()
    }

    private let updateAppearanceSubject = PassthroughSubject<Void, Never>()
    var updateAppearancePublisher: AnyPublisher<Void, Never> {
        return updateAppearanceSubject.eraseToAnyPublisher()
    }

    var updateImageHandler: (([[DayData]], GGColor, GGStyle, GGPeriod) -> Void)?

    init() {}

    func openPreferences() {
        openWindowSubject.send(.preferences)
    }

    func openAbout() {
        openWindowSubject.send(.about)
    }

    func terminateApp() {
        NSApp.terminate(nil)
    }

    func updateAppearance() {
        updateAppearanceSubject.send(())
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class MenuBarModelMock: MenuBarModel {
        var openWindowPublisher: AnyPublisher<WindowType, Never> {
            return Just(.preferences).eraseToAnyPublisher()
        }
        var updateAppearancePublisher: AnyPublisher<Void, Never> {
            return Just(()).eraseToAnyPublisher()
        }
        var updateImageHandler: (([[DayData]], GGColor, GGStyle, GGPeriod) -> Void)?

        func openPreferences() {}
        func openAbout() {}
        func terminateApp() {}
        func updateAppearance() {}
    }
}

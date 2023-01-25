//
//  GitGrassAppModel.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import AppKit
import Combine

protocol GitGrassAppModel: ObservableObject {
    associatedtype UR: UserDefaultsRepository
    associatedtype LR: LaunchAtLoginRepository

    var userDefaultsRepository: UR { get }
    var launchAtLoginRepository: LR { get }
}

final class GitGrassAppModelImpl: NSObject, GitGrassAppModel {
    typealias UR = UserDefaultsRepositoryImpl
    typealias LR = LaunchAtLoginRepositoryImpl

    let userDefaultsRepository: UR
    let launchAtLoginRepository: LR
    private let gitGrassManager: GitGrassManagerImpl
    private let menuBarModel: MenuBarModelImpl
    private var menuBar: MenuBar<MenuBarModelImpl>?
    private var cancellables = Set<AnyCancellable>()

    private var settingsWindow: NSWindow? {
        return NSApp.windows.first(where: { window in
            window.frameAutosaveName == "com_apple_SwiftUI_Settings_window"
        })
    }

    override init() {
        userDefaultsRepository = UR()
        launchAtLoginRepository = LR()
        gitGrassManager = GitGrassManagerImpl()
        menuBarModel = MenuBarModelImpl()
        super.init()

        NotificationCenter.default.publisher(for: NSApplication.didFinishLaunchingNotification)
            .sink { [weak self] _ in
                self?.applicationDidFinishLaunching()
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.applicationWillTerminate()
            }
            .store(in: &cancellables)
    }

    private func applicationDidFinishLaunching() {
        menuBar = MenuBar(menuBarModel: menuBarModel)

        userDefaultsRepository.usernamePublisher
            .sink { [weak self] username in
                self?.gitGrassManager.fetchGrass(username: username)
            }
            .store(in: &cancellables)
        userDefaultsRepository.cyclePublisher
            .sink { [weak self] (username, cycle) in
                self?.gitGrassManager.updateCycle(username: username, cycle: cycle)
            }
            .store(in: &cancellables)
        userDefaultsRepository.propertiesPublisher
            .sink { [weak self] (color, style, period) in
                guard let self else { return }
                let dayData = self.gitGrassManager.currentDayData
                self.menuBarModel.updateImageHandler?(dayData, color, style, period)
            }
            .store(in: &cancellables)
        gitGrassManager.dayDataPublisher
            .sink { [weak self] dayData in
                guard let self else { return }
                let color = self.userDefaultsRepository.color
                let style = self.userDefaultsRepository.style
                let period = self.userDefaultsRepository.period
                self.menuBarModel.updateImageHandler?(dayData, color, style, period)
            }
            .store(in: &cancellables)
        menuBarModel.openWindowPublisher
            .sink { [weak self] windowType in
                switch windowType {
                case .preferences:
                    self?.openPreferences()
                case .about:
                    self?.openAbout()
                }
            }
            .store(in: &cancellables)
        menuBarModel.updateAppearancePublisher
            .sink { [weak self] in
                guard let self else { return }
                let dayData = self.gitGrassManager.currentDayData
                let color = self.userDefaultsRepository.color
                let style = self.userDefaultsRepository.style
                let period = self.userDefaultsRepository.period
                self.menuBarModel.updateImageHandler?(dayData, color, style, period)
            }
            .store(in: &cancellables)

        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.willSleepNotification)
            .sink { [weak self] _ in
                self?.gitGrassManager.stopTimer()
            }
            .store(in: &cancellables)

        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didWakeNotification)
            .sink { [weak self] _ in
                self?.startTimer()
            }
            .store(in: &cancellables)

        startTimer()
        if userDefaultsRepository.username.isEmpty {
            openPreferences()
        }
    }

    private func applicationWillTerminate() {
        gitGrassManager.stopTimer()
    }

    private func openPreferences() {
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        guard let window = settingsWindow else { return }
        if window.canBecomeMain {
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func openAbout() {
        NSApp.activate(ignoringOtherApps: true)
        let mutableAttrStr = NSMutableAttributedString()
        var attr: [NSAttributedString.Key : Any] = [.foregroundColor : NSColor.textColor]
        mutableAttrStr.append(NSAttributedString(string: "oss".localized, attributes: attr))
        let url = "https://github.com/Kyome22/GitGrass"
        attr = [.foregroundColor : NSColor.url, .link : url]
        mutableAttrStr.append(NSAttributedString(string: url, attributes: attr))
        let key = NSApplication.AboutPanelOptionKey.credits
        NSApp.orderFrontStandardAboutPanel(options: [key: mutableAttrStr])
    }

    private func startTimer() {
        let username = userDefaultsRepository.username
        let cycle = userDefaultsRepository.cycle
        gitGrassManager.startTimer(username: username, cycle: cycle)
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class GitGrassAppModelMock: GitGrassAppModel {
        typealias UR = UserDefaultsRepositoryMock
        typealias LR = LaunchAtLoginRepositoryMock

        var userDefaultsRepository = UR()
        var launchAtLoginRepository = LR()
    }
}

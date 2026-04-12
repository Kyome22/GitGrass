/*
 MenuStore.swift
 Model

 Created by Takuto Nakamura on 2024/11/24.
 Copyright 2022 Takuto Nakamura

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
import DataSource
import Observation

@MainActor @Observable
public final class MenuStore: NSObject, Composable {
    private let dependencyListClient: DependencyListClient
    private let nsAppClient: NSAppClient
    private let nsWorkspaceClient: NSWorkspaceClient
    private let logService: LogService
    private var licensesWindow: NSWindow?

    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        licensesWindow: NSWindow? = nil,
        action: @escaping (Action) async -> Void =  { _ in }
    ) {
        self.dependencyListClient = appDependencies.dependencyListClient
        self.nsAppClient = appDependencies.nsAppClient
        self.nsWorkspaceClient = appDependencies.nsWorkspaceClient
        self.logService = .init(appDependencies)
        self.licensesWindow = licensesWindow
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))

        case .settingsLinkTapped:
            nsAppClient.activate(true)

        case let .aboutButtonTapped(body):
            nsAppClient.activate(true)
            nsAppClient.orderFrontStandardAboutPanel([
                NSApplication.AboutPanelOptionKey.credits : NSAttributedString(body)
            ])

        case .licensesButtonTapped:
            if licensesWindow == nil {
                nsAppClient.activate(true)
                licensesWindow = dependencyListClient.window()
                licensesWindow?.isReleasedWhenClosed = false
                licensesWindow?.delegate = self
                licensesWindow?.center()
                licensesWindow?.orderFrontRegardless()
            } else {
                nsAppClient.activate(true)
                licensesWindow?.orderFrontRegardless()
            }

        case .quitButtonTapped:
            nsAppClient.terminate(nil)

        case .debugSleepButtonTapped:
            nsWorkspaceClient.post(NSWorkspace.willSleepNotification, nil)

        case .debugWakeUpButtonTapped:
            nsWorkspaceClient.post(NSWorkspace.didWakeNotification, nil)
        }
    }

    public enum Action: Sendable {
        case task(String)
        case settingsLinkTapped
        case aboutButtonTapped(AttributedString)
        case licensesButtonTapped
        case quitButtonTapped
        case debugSleepButtonTapped
        case debugWakeUpButtonTapped
    }
}

extension MenuStore: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window === licensesWindow {
            licensesWindow = nil
        }
    }
}

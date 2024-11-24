/*
 MenuViewModel.swift
 Domain

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
import DataLayer
import Foundation
import Observation

@MainActor @Observable public final class MenuViewModel: NSObject {
    private let dependencyListClient: DependencyListClient
    private let nsAppClient: NSAppClient
    private let logService: LogService
    private var licensesWindow: NSWindow?

    public init(
        _ dependencyListClient: DependencyListClient,
        _ nsAppClient: NSAppClient,
        _ logService: LogService
    ) {
        self.dependencyListClient = dependencyListClient
        self.nsAppClient = nsAppClient
        self.logService = logService
    }

    public func onAppear(screenName: String) {
        logService.notice(.screenView(name: screenName))
    }

    public func activateApp() {
        nsAppClient.activate(true)
    }

    public func openAbout(with options: [NSApplication.AboutPanelOptionKey : Any]) {
        nsAppClient.activate(true)
        nsAppClient.orderFrontStandardAboutPanel(options)
    }

    public func openLicenses() {
        if licensesWindow == nil {
            nsAppClient.activate(true)
            licensesWindow = dependencyListClient.window()
            licensesWindow?.delegate = self
            licensesWindow?.center()
            licensesWindow?.orderFrontRegardless()
        } else {
            nsAppClient.activate(true)
            licensesWindow?.orderFrontRegardless()
        }
    }

    public func terminateApp() {
        nsAppClient.terminate(nil)
    }
}

extension MenuViewModel: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window === licensesWindow {
            licensesWindow = nil
        }
    }
}

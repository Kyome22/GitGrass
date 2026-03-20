/*
 AppAlertStore.swift
 Model

 Created by Takuto Nakamura on 2026/03/20.
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

import DataSource
import Observation

@MainActor @Observable
public final class AppAlertStore: Composable {
    private let appStateClient: AppStateClient

    @ObservationIgnored private var task: Task<Void, Never>?

    public var showingAlert: Bool
    public var error: GGError?
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        showingAlert: Bool = false,
        error: GGError? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.appStateClient = appDependencies.appStateClient
        self.showingAlert = showingAlert
        self.error = error
        self.action = action
        bind()
    }

    deinit {
        task?.cancel()
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .errorReceived(error):
            self.error = error
            showingAlert = true
        }
    }

    private func bind() {
        task = Task { [weak self, appStateClient] in
            let values = appStateClient.withLock(\.errorSubject.values)
            for await value in values {
                await self?.send(.errorReceived(value))
            }
        }
    }

    public enum Action: Sendable {
        case errorReceived(GGError)
    }
}

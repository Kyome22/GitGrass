/*
 AppStateClient.swift
 DataSource

 Created by Takuto Nakamura on 2026/03/15.
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

import Combine
import os

public struct AppStateClient: DependencyClient {
    var getAppState: @Sendable () -> AppState
    var setAppState: @Sendable (AppState) -> Void
    var receive: SubjectReceiveAction

    public func withLock<R: Sendable>(_ body: @Sendable (inout AppState) throws -> R) rethrows -> R {
        var state = getAppState()
        let result = try body(&state)
        setAppState(state)
        return result
    }

    public func send<S: Subject>(_ keyPath: KeyPath<AppState, S>, input: S.Output) {
        let state = getAppState()
        state[keyPath: keyPath].send(input)
        receive(keyPath, input: input)
    }

    public static let liveValue: Self = {
        let state = OSAllocatedUnfairLock<AppState>(initialState: .init())
        return Self(
            getAppState: { state.withLock(\.self) },
            setAppState: { value in state.withLock { $0 = value } },
            receive: .init(action: { _, _ in })
        )
    }()

    public static let testValue = Self(
        getAppState: { .init() },
        setAppState: { _ in },
        receive: .init(action: { _, _ in })
    )

    public static func testDependency(
        _ appState: OSAllocatedUnfairLock<AppState>,
        receive: SubjectReceiveAction? = nil
    ) -> Self {
        Self(
            getAppState: { appState.withLock(\.self) },
            setAppState: { value in appState.withLock { $0 = value } },
            receive: receive ?? .init(action: { _, _ in })
        )
    }

    public struct SubjectReceiveAction: Sendable {
        let action: @Sendable (AnyKeyPath, Any) -> Void

        func callAsFunction<S: Subject>(_ keyPath: KeyPath<AppState, S>, input: S.Output) {
            action(keyPath, input)
        }
    }
}

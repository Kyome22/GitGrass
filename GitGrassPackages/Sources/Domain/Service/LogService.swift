/*
 LogService.swift
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

import DataLayer
import Foundation
import Logging

public actor LogService {
    private var hasAlreadyBootstrap = false
    private let loggingSystemClient: LoggingSystemClient

    public init(_ loggingSystemClient: LoggingSystemClient) {
        self.loggingSystemClient = loggingSystemClient
    }

    public func bootstrap() {
        guard !hasAlreadyBootstrap else { return }
#if DEBUG
        loggingSystemClient.bootstrap { label in
            StreamLogHandler.standardOutput(label: label)
        }
#endif
        hasAlreadyBootstrap = true
    }

    public nonisolated func notice(
        _ event: NoticeEvent,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        Logger(label: Bundle.main.bundleIdentifier!).notice(
            event.message,
            metadata: event.metadata,
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }

    public nonisolated func error(
        _ event: ErrorEvent,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        Logger(label: Bundle.main.bundleIdentifier!).error(
            event.message,
            metadata: event.metadata,
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }

    public nonisolated func critical(
        _ event: CriticalEvent,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        Logger(label: Bundle.main.bundleIdentifier!).critical(
            event.message,
            metadata: event.metadata,
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }
}

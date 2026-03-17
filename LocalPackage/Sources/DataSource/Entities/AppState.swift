/*
 AppState.swift
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

public struct AppState: Sendable {
    public var name: String
    public var version: String
    public var hasAlreadyBootstrap = false
    public let errorSubject = PassthroughSubject<GGError, Never>()
    public let cycleSubject = PassthroughSubject<Void, Never>()
    public let imagePropertiesSubject = CurrentValueSubject<ImageProperties, Never>(.default)

    init(
        name: String = "",
        version: String = "",
        hasAlreadyBootstrap: Bool = false
    ) {
        self.name = name
        self.version = version
        self.hasAlreadyBootstrap = hasAlreadyBootstrap
    }
}

extension AsyncPublisher: @retroactive @unchecked Sendable {}
extension CurrentValueSubject: @retroactive @unchecked Sendable where Failure == Never, Output : Sendable {}
extension PassthroughSubject: @retroactive @unchecked Sendable where Failure == Never, Output : Sendable {}

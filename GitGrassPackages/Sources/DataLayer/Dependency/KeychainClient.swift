/*
 KeychainClient.swift
 DataLayer

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

import KeychainAccess

public struct KeychainClient: DependencyClient {
    public var getString: @Sendable (String) throws -> String?
    public var set: @Sendable (String, String) throws -> Void
    public var remove: @Sendable (String) throws -> Void

    public static let liveValue = Self(
        getString: { try Keychain().getString($0) },
        set: { try Keychain().set($0, key: $1) },
        remove: { try Keychain().remove($0) }
    )

    public static let testValue = Self(
        getString: { _ in nil },
        set: { _, _ in },
        remove: { _ in }
    )
}

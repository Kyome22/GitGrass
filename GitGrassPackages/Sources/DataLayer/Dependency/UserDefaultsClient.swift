/*
 UserDefaultsClient.swift
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

import Foundation

public struct UserDefaultsClient: DependencyClient {
    var integer: @Sendable (String) -> Int
    var setInteger: @Sendable (Int, String) -> Void
    var string: @Sendable (String) -> String?
    var setString: @Sendable (String, String) -> Void
    var register: @Sendable ([String : Any]) -> Void
    var removePersistentDomain: @Sendable (String) -> Void
    var persistentDomain: @Sendable (String) -> [String : Any]?

    public static let liveValue = Self(
        integer: { UserDefaults.standard.integer(forKey: $0) },
        setInteger: { UserDefaults.standard.set($0, forKey: $1) },
        string: { UserDefaults.standard.string(forKey: $0) },
        setString: { UserDefaults.standard.set($0, forKey: $1) },
        register: { UserDefaults.standard.register(defaults: $0) },
        removePersistentDomain: { UserDefaults.standard.removePersistentDomain(forName: $0) },
        persistentDomain: { UserDefaults.standard.persistentDomain(forName: $0) }
    )

    public static let testValue = Self(
        integer: { _ in .zero },
        setInteger: { _, _ in },
        string: { _ in nil },
        setString: { _, _ in },
        register: { _ in },
        removePersistentDomain: { _ in },
        persistentDomain: { _ in nil }
    )
}

extension UserDefaults: @retroactive @unchecked Sendable {}

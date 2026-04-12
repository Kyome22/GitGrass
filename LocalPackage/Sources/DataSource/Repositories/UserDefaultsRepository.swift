/*
 UserDefaultsRepository.swift
 DataSource

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

public struct UserDefaultsRepository: Sendable {
    private var userDefaultsClient: UserDefaultsClient

    public var username: String {
        get { userDefaultsClient.string(.username) ?? "" }
        nonmutating set { userDefaultsClient.setString(newValue, .username) }
    }

    public var cycle: GGCycle {
        get { GGCycle(rawValue: userDefaultsClient.integer(.cycle)) ?? .minutes5 }
        nonmutating set { userDefaultsClient.setInteger(newValue.rawValue, .cycle) }
    }

    public var color: GGColor {
        get { GGColor(rawValue: userDefaultsClient.integer(.color)) ?? .monochrome }
        nonmutating set { userDefaultsClient.setInteger(newValue.rawValue, .color) }
    }

    public var style: GGStyle {
        get { GGStyle(rawValue: userDefaultsClient.integer(.style)) ?? .block }
        nonmutating set { userDefaultsClient.setInteger(newValue.rawValue, .style) }
    }

    public var period: GGPeriod {
        get { GGPeriod(rawValue: userDefaultsClient.integer(.period)) ?? .lastYear }
        nonmutating set { userDefaultsClient.setInteger(newValue.rawValue, .period) }
    }

    public init(_ userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient

#if DEBUG
        if ProcessInfo.needsResetUserDefaults {
            userDefaultsClient.removePersistentDomain(Bundle.main.bundleIdentifier!)
        }
        showAllData()
#endif
    }

    private func showAllData() {
        guard let dict = userDefaultsClient.persistentDomain(Bundle.main.bundleIdentifier!) else {
            return
        }
        for (key, value) in dict.sorted(by: { $0.0 < $1.0 }) {
            Swift.print("\(key) => \(value)")
        }
    }
}

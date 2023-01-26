//
//  UserDefaultsRepository.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//  Copyright 2023 Takuto Nakamura
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Combine

fileprivate let RESET_USER_DEFAULTS = false
typealias GGProperties = (GGColor, GGStyle, GGPeriod)

protocol UserDefaultsRepository: AnyObject {
    var usernamePublisher: AnyPublisher<String, Never> { get }
    var cyclePublisher: AnyPublisher<GGCycle, Never> { get }
    var propertiesPublisher: AnyPublisher<GGProperties, Never> { get }

    var username: String { get set }
    var cycle: GGCycle { get set }
    var color: GGColor { get set }
    var style: GGStyle { get set }
    var period: GGPeriod { get set }
}

final class UserDefaultsRepositoryImpl: UserDefaultsRepository {
    private let userDefaults: UserDefaults

    private let usernameSubject = PassthroughSubject<String, Never>()
    var usernamePublisher: AnyPublisher<String, Never> {
        return usernameSubject.eraseToAnyPublisher()
    }

    private let cycleSubject = PassthroughSubject<GGCycle, Never>()
    var cyclePublisher: AnyPublisher<GGCycle, Never> {
        return cycleSubject.eraseToAnyPublisher()
    }

    private let propertiesSubject = PassthroughSubject<GGProperties, Never>()
    var propertiesPublisher: AnyPublisher<GGProperties, Never> {
        return propertiesSubject.eraseToAnyPublisher()
    }

    var username: String {
        get { userDefaults.string(forKey: "username")! }
        set {
            userDefaults.set(newValue, forKey: "username")
            usernameSubject.send(newValue)
        }
    }

    var cycle: GGCycle {
        get { GGCycle(rawValue: userDefaults.integer(forKey: "cycle"))! }
        set {
            userDefaults.set(newValue.rawValue, forKey: "cycle")
            cycleSubject.send(newValue)
        }
    }

    var color: GGColor {
        get { GGColor(rawValue: userDefaults.integer(forKey: "color"))! }
        set {
            userDefaults.set(newValue.rawValue, forKey: "color")
            propertiesSubject.send((newValue, style, period))
        }
    }

    var style: GGStyle {
        get { GGStyle(rawValue: userDefaults.integer(forKey: "style"))! }
        set {
            userDefaults.set(newValue.rawValue, forKey: "style")
            propertiesSubject.send((color, newValue, period))
        }
    }

    var period: GGPeriod {
        get { GGPeriod(rawValue: userDefaults.integer(forKey: "period"))! }
        set {
            userDefaults.set(newValue.rawValue, forKey: "period")
            propertiesSubject.send((color, style, newValue))
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
#if DEBUG
        if RESET_USER_DEFAULTS {
            self.userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
#endif
        self.userDefaults.register(defaults: [
            "username" : "",
            "cycle" : GGCycle.minutes5.rawValue,
            "color" : GGColor.monochrome.rawValue,
            "style" : GGStyle.block.rawValue,
            "period": GGPeriod.lastYear.rawValue
        ])
#if DEBUG
        showAllData()
#endif
    }

    private func showAllData() {
        if let dict = userDefaults.persistentDomain(forName: Bundle.main.bundleIdentifier!) {
            for (key, value) in dict.sorted(by: { $0.0 < $1.0 }) {
                Swift.print("\(key) => \(value)")
            }
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class UserDefaultsRepositoryMock: UserDefaultsRepository {
        var usernamePublisher: AnyPublisher<String, Never> {
            return Just(username).eraseToAnyPublisher()
        }
        var cyclePublisher: AnyPublisher<GGCycle, Never> {
            return Just(cycle).eraseToAnyPublisher()
        }
        var propertiesPublisher: AnyPublisher<GGProperties, Never> {
            return Just((color, style, period)).eraseToAnyPublisher()
        }

        var username: String = ""
        var cycle: GGCycle = .minutes5
        var color: GGColor = .monochrome
        var style: GGStyle = .block
        var period: GGPeriod = .lastYear
    }
}

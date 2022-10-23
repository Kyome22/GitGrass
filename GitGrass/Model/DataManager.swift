//
//  DataManager.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2022/10/11.
//  Copyright 2022 Takuto Nakamura
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

final class DataManager {
    static let shared = DataManager()
    private let userDefaults = UserDefaults.standard

    var username: String {
        get { return userDefaults.string(forKey: "username")! }
        set { userDefaults.set(newValue, forKey: "username") }
    }

    var cycle: GGCycle {
        get { return GGCycle(rawValue: userDefaults.integer(forKey: "cycle"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "cycle") }
    }

    var color: GGColor {
        get { return GGColor(rawValue: userDefaults.integer(forKey: "color"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "color") }
    }

    var style: GGStyle {
        get { return GGStyle(rawValue: userDefaults.integer(forKey: "style"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "style") }
    }

    var period: GGPeriod {
        get { return GGPeriod(rawValue: userDefaults.integer(forKey: "period"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "period") }
    }

    private init() {
        // userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefaults.register(defaults: ["username" : "",
                                         "cycle" : GGCycle.minutes5.rawValue,
                                         "color" : GGColor.monochrome.rawValue,
                                         "style" : GGStyle.block.rawValue,
                                         "period": GGPeriod.lastYear.rawValue])
    }
}

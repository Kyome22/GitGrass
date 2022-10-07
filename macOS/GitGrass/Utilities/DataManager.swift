//
//  DataManager.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/19.
//  Copyright 2019 Takuto Nakamura
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

class DataManager {
    
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    
    var username: String {
        get { return userDefaults.string(forKey: "username")! }
        set { userDefaults.set(newValue, forKey: "username") }
    }
    
    var cycle: Int {
        get { return userDefaults.integer(forKey: "cycle") }
        set { userDefaults.set(newValue, forKey: "cycle") }
    }
    
    var color: Color {
        get { return Color(rawValue: userDefaults.integer(forKey: "color"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "color") }
    }
    
    var style: Style {
        get { return Style(rawValue: userDefaults.integer(forKey: "style"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "style") }
    }

    var history: History {
        get { return History(rawValue: userDefaults.integer(forKey: "history"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "history") }
    }

    private init() {
        // userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefaults.register(defaults: ["username" : "",
                                         "cycle" : 5,
                                         "color" : Color.monochrome.rawValue,
                                         "style" : Style.block.rawValue,
                                         "history": History.all.rawValue])
    }
    
}

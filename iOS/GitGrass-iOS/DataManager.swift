//
//  DataManager.swift
//  GitGrass-iOS
//
//  Created by Takuto Nakamura on 2020/03/22.
//  Copyright 2020 Takuto Nakamura
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
    
    private let userDefaults = UserDefaults(suiteName: "group.com.kyome.GitGrass-iOS")!
    
    var username: String {
        get {
            return userDefaults.string(forKey: "username")!
        }
        set(newName) {
            userDefaults.set(newName, forKey: "username")
            userDefaults.synchronize()
        }
    }
    
    var dayData: [[DayData]] {
        get {
            guard
                let data = userDefaults.data(forKey: "dayData"),
                let unarchived = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data),
                let dayData = unarchived as? [[DayData]]
                else {
                return DayData.default
            }
            return dayData
        }
        set(newDayData) {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newDayData,
                                                         requiringSecureCoding: true)
            userDefaults.set(data, forKey: "dayData")
            userDefaults.synchronize()
        }
    }
    
    var color: Color {
        get {
            return Color(rawValue: userDefaults.integer(forKey: "color"))!
        }
        set(newColor) {
            userDefaults.set(newColor.rawValue, forKey: "color")
            userDefaults.synchronize()
        }
    }
    
    var style: Style {
        get {
            return Style(rawValue: userDefaults.integer(forKey: "style"))!
        }
        set(newStyle) {
            userDefaults.set(newStyle.rawValue, forKey: "style")
            userDefaults.synchronize()
        }
    }
    
    private init() {
        // userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier)!
        userDefaults.register(defaults: ["username" : ""])
    }
    
}

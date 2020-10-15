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
        get { return userDefaults.string(forKey: "username")! }
        set { userDefaults.set(newValue, forKey: "username") }
    }
    
    var dayData: [[DayData]] {
        get {
            guard let data = userDefaults.data(forKey: "dayData"),
                  let unarchived = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data),
                  let dayData = unarchived as? [[DayData]]
            else { return DayData.default }
            return dayData
        }
        set {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue,
                                                         requiringSecureCoding: true)
            userDefaults.set(data, forKey: "dayData")
        }
    }
    
    var color: GGColor {
        get { return GGColor(rawValue: userDefaults.integer(forKey: "color"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "color") }
    }
    
    var style: GGStyle {
        get { return GGStyle(rawValue: userDefaults.integer(forKey: "style"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "style") }
    }
    
    var labelText: String {
        if username.isEmpty {
            return "NoAccount".localized
        }
        return "Contributions".localized
            .replacingOccurrences(of: "USERNAME", with: username)
    }
    
    private init() {
        NSKeyedArchiver.setClassName("DayData", for: DayData.self)
        NSKeyedUnarchiver.setClass(DayData.self, forClassName: "DayData")
        // userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier)!
        userDefaults.register(defaults: ["username" : ""])
    }
    
}

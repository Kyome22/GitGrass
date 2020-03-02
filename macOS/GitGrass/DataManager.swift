//
//  DataManager.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2020/03/02.
//  Copyright © 2020 Takuto Nakamura. All rights reserved.
//

import Foundation

class DataManager {
    
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    
    var username: String {
        get {
            return userDefaults.string(forKey: "username")!
        }
        set(newName) {
            userDefaults.set(newName, forKey: "username")
            userDefaults.synchronize()
        }
    }
    var cycle: Int {
        get {
            return userDefaults.integer(forKey: "cycle")
        }
        set(newCycle) {
            userDefaults.set(newCycle, forKey: "cycle")
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
        // userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefaults.register(defaults: ["username" : "",
                                         "cycle" : 5,
                                         "style" : Style.mono.rawValue])
    }
    
}

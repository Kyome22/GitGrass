//
//  AppDelegate.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/21.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let userDefaults = UserDefaults(suiteName: "group.com.kyome.iOS.GitGrass")!
    var username: String {
        get {
            return userDefaults.string(forKey: "username") ?? ""
        }
        set(newname) {
            userDefaults.set(newname, forKey: "username")
            userDefaults.synchronize()
        }
    }
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        userDefaults.register(defaults: ["username" : ""])
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func fetchGrass(callback: @escaping (_ dayData: [[DayData]]) -> Void) {
        GitAccess.getGrass(username: username) { (html) in
            let dayData: [[DayData]]
            if let html = html {
                dayData = GrassParser.parse(html: html)
            } else {
                let dummy = DayData(level: 0, count: 0, date: "dummy")
                dayData = [[DayData]](repeating: [dummy], count: 7)
            }
            callback(dayData)
        }
    }

}


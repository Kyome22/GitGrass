//
//  TodayViewController.swift
//  GitGrassExtension
//
//  Created by Takuto Nakamura on 2019/11/21.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var grassView: GrassView!
    
    let userDefaults = UserDefaults(suiteName: "group.com.kyome.iOS.GitGrass")!
    var username: String {
        return userDefaults.string(forKey: "username")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userDefaults.register(defaults: ["username" : ""])
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        GitAccess.getGrass(username: self.username) { [weak self] (html) in
            if let html = html {
                self?.updateGrass(by: GrassParser.parse(html: html))
                completionHandler(NCUpdateResult.newData)
            } else {
                completionHandler(NCUpdateResult.failed)
            }
        }
    }
    
    func updateGrass(by dayData: [[DayData]]) {
        DispatchQueue.main.async {
            self.label.text = "Contributions of \(self.username)"
            self.grassView.update(by: dayData, isEX: true)
        }
    }
    
}

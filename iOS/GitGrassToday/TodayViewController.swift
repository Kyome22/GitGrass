//
//  TodayViewController.swift
//  GitGrassToday
//
//  Created by Takuto Nakamura on 2020/03/22.
//  Copyright © 2020 Takuto Nakamura. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var grassView: GrassView!
    
    let dm = DataManager.shared
    
    var labelText: String {
        if dm.username.isEmpty {
            return "NoAccount".localized
        }
        return "Contributions".localized.replacingOccurrences(of: "USERNAME", with: dm.username)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSKeyedArchiver.setClassName("DayData", for: DayData.self)
        NSKeyedUnarchiver.setClass(DayData.self, forClassName: "DayData")
        updateUI()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        if dm.username.isEmpty {
            self.updateUI()
            completionHandler(NCUpdateResult.failed)
            return
        }
        GitAccess.getGrass(username: dm.username) { [weak self] (username, html) in
            if let html = html {
                self?.dm.dayData = GrassParser.parse(html: html)
                completionHandler(NCUpdateResult.newData)
            } else {
                self?.dm.dayData = DayData.default
                completionHandler(NCUpdateResult.failed)
            }
            self?.updateUI()
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.label.text = self.labelText
            self.grassView.update(self.dm.dayData, self.dm.color, self.dm.style)
        }
    }
    
}

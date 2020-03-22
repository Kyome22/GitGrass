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
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        if dm.username.isEmpty {
            DispatchQueue.main.async {
                self.label.text = "NoAccount".localized
                self.grassView.update(with: DayData.default)
            }
            completionHandler(NCUpdateResult.failed)
            return
        }
        GitAccess.getGrass(username: dm.username) { [weak self] (username, html) in
            let dayData: [[DayData]]
            if let html = html {
                dayData = GrassParser.parse(html: html)
                completionHandler(NCUpdateResult.newData)
            } else {
                dayData = DayData.default
                completionHandler(NCUpdateResult.failed)
            }
            DispatchQueue.main.async {
                self?.label.text = "Contributions".localized.replacingOccurrences(of: "USERNAME", with: username)
                self?.grassView.update(with: dayData)
            }
        }
    }
    
}

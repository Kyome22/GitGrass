//
//  SettingsVC.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/19.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

class SettingsVC: NSViewController {
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var cyclePopUp: NSPopUpButton!
    @IBOutlet weak var stylePopUp: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.stringValue = AppDelegate.shared.username
        let cycle = AppDelegate.shared.cycle
        cyclePopUp.selectItem(withTag: cycle)
        let style = AppDelegate.shared.style
        stylePopUp.selectItem(at: style == "mono" ? 0 : 1)
    }
    
    @IBAction func cycleChange(_ sender: NSPopUpButton) {
        AppDelegate.shared.cycle = sender.tag
    }
    
    @IBAction func styleChange(_ sender: NSPopUpButton) {
        AppDelegate.shared.style = (sender.indexOfSelectedItem == 0) ? "mono" : "grass"
        AppDelegate.shared.fetchGrass()
    }
    
}

extension SettingsVC: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        AppDelegate.shared.username = textField.stringValue
        AppDelegate.shared.fetchGrass()
    }
    
}

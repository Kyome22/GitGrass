//
//  PreferencesVC.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/19.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

class PreferencesVC: NSViewController {
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var cyclePopUp: NSPopUpButton!
    @IBOutlet weak var stylePopUp: NSPopUpButton!
    
    private let dm = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.stringValue = dm.username
        cyclePopUp.selectItem(withTag: dm.cycle)
        stylePopUp.selectItem(at: dm.style == .mono ? 0 : 1)
    }
    
    @IBAction func cycleChange(_ sender: NSPopUpButton) {
        dm.cycle = sender.selectedTag()
        AppDelegate.shared.stopTimer()
        AppDelegate.shared.startTimer()
    }
    
    @IBAction func styleChange(_ sender: NSPopUpButton) {
        dm.style = Style(rawValue: sender.indexOfSelectedItem)!
        AppDelegate.shared.fetchGrass()
    }
    
}

extension PreferencesVC: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        dm.username = textField.stringValue
        AppDelegate.shared.fetchGrass()
    }
    
}

class PreferencesWindow: NSWindow {
    
    override func cancelOperation(_ sender: Any?) {
        self.close()
    }
    
}

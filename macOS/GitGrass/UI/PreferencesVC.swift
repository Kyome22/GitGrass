//
//  PreferencesVC.swift
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
    
    func showAlert(error: Error) {
        guard let window = self.view.window else { return }
        let alert = NSAlert(error: error)
        alert.beginSheetModal(for: window, completionHandler: nil)
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

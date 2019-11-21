//
//  ViewController.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/21.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var grassView: GrassView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.text = AppDelegate.shared.username
        reload(true)
    }
    
    @IBAction func tapView(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func reload(_ sender: Any) {
        AppDelegate.shared.fetchGrass { (dayData) in
            self.updateGrass(by: dayData)
        }
    }
    
    func updateGrass(by dayData: [[DayData]]) {
        DispatchQueue.main.async {
            self.grassView.update(by: dayData, isEX: false)
        }
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        AppDelegate.shared.username = textField.text ?? ""
        reload(true)
    }
    
}

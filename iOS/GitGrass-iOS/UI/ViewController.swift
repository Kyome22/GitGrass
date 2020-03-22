//
//  ViewController.swift
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

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var grassView: GrassView!
    @IBOutlet weak var versionLabel: UILabel!
    
    private let dm = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.text = dm.username
        reloadButton.isEnabled = false
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        fetch(username: dm.username)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [.portrait, .portraitUpsideDown]
        }
        return .all
    }

    @IBAction func tap(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func reload(_ sender: Any) {
        fetch(username: dm.username)
    }
    
    @IBAction func jumpSource(_ sender: Any) {
        guard
            let url = URL(string: "https://github.com/Kyome22/GitGrass"),
            UIApplication.shared.canOpenURL(url)
            else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func fetch(username: String) {
        if username.isEmpty {
            reloadButton.isEnabled = false
            grassView.update(with: DayData.default)
            return
        }
        GitAccess.getGrass(username: username) { [weak self] (username, html) in
            let dayData: [[DayData]]
            if let html = html {
                dayData = GrassParser.parse(html: html)
                self?.dm.username = username
            } else {
                dayData = DayData.default
                self?.dm.username = ""
                self?.showAlert(username)
            }
            DispatchQueue.main.async {
                self?.textField.text = self?.dm.username
                self?.reloadButton.isEnabled = (html != nil)
                self?.grassView.update(with: dayData)
            }
        }
    }
    
    func showAlert(_ username: String) {
        DispatchQueue.main.async {
            let title = "AlertTitle".localized.replacingOccurrences(of: "USERNAME", with: username)
            let alert = UIAlertController(title: title,
                                          message: "AlertMessage".localized,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        fetch(username: textField.text ?? "")
    }
    
}

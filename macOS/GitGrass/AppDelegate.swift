//
//  AppDelegate.swift
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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    private let dm = DataManager.shared
    private let nc = NSWorkspace.shared.notificationCenter
    private let statusItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.variableLength)
    private var button: NSStatusBarButton?
    private let grassView = GrassView()
    private var timer: Timer?
    private var preferencesWC: NSWindowController?
    
    class var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setNotifications()
        setUserInterface()
        startTimer()
        if dm.username.isEmpty {
            openPreferences(nil)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        stopTimer()
        nc.removeObserver(self)
    }

    
    func setNotifications() {
        nc.addObserver(self, selector: #selector(receiveSleepNote),
                       name: NSWorkspace.willSleepNotification, object: nil)
        nc.addObserver(self, selector: #selector(receiveWakeNote),
                       name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    @objc func receiveSleepNote() {
        stopTimer()
    }
    
    @objc func receiveWakeNote() {
        startTimer()
    }
    
    func setUserInterface() {
        statusItem.menu = menu
        statusItem.length = 130.5
        button = statusItem.button
        button?.addSubview(grassView)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: Double(dm.cycle * 60), repeats: true, block: { (_) in
            self.fetchGrass()
        })
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        timer?.fire()
    }
        
    @IBAction func openPreferences(_ sender: Any?) {
        if preferencesWC == nil {
            let sb = NSStoryboard(name: "Preferences", bundle: nil)
            preferencesWC = (sb.instantiateInitialController() as! NSWindowController)
            preferencesWC!.window?.delegate = self
        }
        NSApp.activate(ignoringOtherApps: true)
        preferencesWC!.showWindow(nil)
    }
    
    @IBAction func openAbout(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        let mutableAttrStr = NSMutableAttributedString()
        var attr: [NSAttributedString.Key : Any] = [.foregroundColor : NSColor.textColor]
        mutableAttrStr.append(NSAttributedString(string: "oss".localized, attributes: attr))
        let url = "https://github.com/Kyome22/GitGrass"
        attr = [.foregroundColor : NSColor.url, .link : url]
        mutableAttrStr.append(NSAttributedString(string: url, attributes: attr))
        let key = NSApplication.AboutPanelOptionKey.credits
        NSApp.orderFrontStandardAboutPanel(options: [key: mutableAttrStr])
    }
    
    func fetchGrass() {
        if dm.username.isEmpty {
            statusItem.length = 130.5
            grassView.update(DayData.default, dm.color, dm.style)
            return
        }
        GitAccess.getGrass(username: dm.username) { [unowned self] (html, error) in
            let dayData: [[DayData]]
            if let html = html {
                dayData = GrassParser.parse(html: html)
            } else {
                dayData = DayData.default
                if let error = error, let wc = self.preferencesWC {
                    DispatchQueue.main.async {
                        (wc.contentViewController as! PreferencesVC).showAlert(error: error)
                    }
                }
            }
            DispatchQueue.main.async {
                self.statusItem.length = 0.5 * CGFloat(5 * dayData[0].count - 1) + 6.0
                self.grassView.update(dayData, self.dm.color, self.dm.style)
            }
        }
    }
    
    func updateGrass() {
        grassView.update(dm.color, dm.style)
    }
    
}

extension AppDelegate: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window == preferencesWC?.window {
            preferencesWC = nil
        }
    }
    
}


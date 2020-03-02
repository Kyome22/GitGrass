//
//  AppDelegate.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/19.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    private let dm = DataManager.shared
    private let nc = NSWorkspace.shared.notificationCenter
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
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
        button = statusItem.button
        button?.addSubview(grassView)
        menu.item(withTag: 0)?.setAction(target: self, selector: #selector(openPreferences))
        menu.item(withTag: 1)?.setAction(target: self, selector: #selector(openAbout))
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
        
    @objc func openPreferences() {
        if preferencesWC == nil {
            let sb = NSStoryboard(name: "Preferences", bundle: nil)
            preferencesWC = (sb.instantiateInitialController() as! NSWindowController)
            preferencesWC!.window?.delegate = self
        }
        NSApp.activate(ignoringOtherApps: true)
        preferencesWC!.showWindow(nil)
    }
    
    @objc func openAbout() {
        NSApp.activate(ignoringOtherApps: true)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let mutableAttrStr = NSMutableAttributedString()
        var attr: [NSAttributedString.Key : Any] = [.foregroundColor : NSColor.textColor, .paragraphStyle : paragraph]
        mutableAttrStr.append(NSAttributedString(string: "oss".localized, attributes: attr))
        let url = "https://github.com/Kyome22/GitGrass"
        attr = [.foregroundColor : NSColor.url, .link : url, .paragraphStyle : paragraph]
        mutableAttrStr.append(NSAttributedString(string: url, attributes: attr))
        let key = NSApplication.AboutPanelOptionKey.credits
        NSApp.orderFrontStandardAboutPanel(options: [key: mutableAttrStr])
    }
    
    func fetchGrass() {
        GitAccess.getGrass(username: dm.username) { [unowned self] (html, error) in
            let dayData: [[DayData]]
            if let html = html {
                dayData = GrassParser.parse(html: html)
            } else {
                dayData = DayData.default
                if let error = error {
                    DispatchQueue.main.async {
                        let alert = NSAlert(error: error)
                        alert.runModal()
                    }
                }
            }
            self.statusItem.length = 0.5 * CGFloat(5 * dayData[0].count - 1)
            DispatchQueue.main.async {
                self.grassView.update(dayData: dayData, style: self.dm.style)
            }
        }
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

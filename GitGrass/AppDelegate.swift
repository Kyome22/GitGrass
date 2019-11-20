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
    
    private let userDefaults = UserDefaults.standard
    private let nc = NSWorkspace.shared.notificationCenter
    private var ao: NSKeyValueObservation?
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var button: NSStatusBarButton?
    private var timer: Timer?
    private var settingsWC: NSWindowController?
    private var dayData = [[DayData]](repeating: [], count: 7)
    
    var username: String {
        get {
            return userDefaults.string(forKey: "username")!
        }
        set(newname) {
            userDefaults.set(newname, forKey: "username")
        }
    }
    var cycle: Int {
        get {
            return userDefaults.integer(forKey: "cycle")
        }
        set(newcycle) {
            userDefaults.set(newcycle, forKey: "cycle")
        }
    }
    var style: String {
        get {
            return userDefaults.string(forKey: "style")!
        }
        set(newstyle) {
            userDefaults.set(newstyle, forKey: "style")
        }
    }
    
    class var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setUserDefaults()
        setNotifications()
        setUserInterface()
        startTimer()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        stopTimer()
        ao?.invalidate()
        nc.removeObserver(self)
    }
    
    func setUserDefaults() {
        userDefaults.register(defaults: ["username" : "",
                                         "cycle" : 5,
                                         "style" : "mono"])
        userDefaults.set(5, forKey: "cycle")
        userDefaults.synchronize()
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
        menu.item(at: 0)?.setAction(target: self, selector: #selector(openSettings))
        menu.item(at: 1)?.setAction(target: self, selector: #selector(openAbout))
        ao = button!.observe(\.effectiveAppearance) { [weak self] (_, _) in
            self?.updateGrass()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: Double(cycle * 60), repeats: true, block: { (_) in
            self.fetchGrass()
        })
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        timer?.fire()
    }
    
    
    @objc func openSettings() {
        if settingsWC == nil {
            let sb = NSStoryboard(name: "Settings", bundle: nil)
            settingsWC = (sb.instantiateInitialController() as! NSWindowController)
            settingsWC!.window?.delegate = self
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWC!.showWindow(nil)
    }
    
    @objc func openAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }
    
    func updateGrass() {
        DispatchQueue.main.async {
            let name = self.button!.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua, .vibrantDark])!
            let isDark = name.rawValue.lowercased().contains("dark")
            self.button?.image = GrassImage.create(from: self.dayData, style: self.style, dark: isDark)
        }
    }
    
    func fetchGrass() {
        GitAccess.getGrass(username: username) { [weak self] (html) in
            if let html = html {
                self?.dayData = GrassParser.parse(html: html)
            } else {
                self?.dayData = [[DayData]](repeating: [DayData(level: 0, count: 0, date: "dummy")], count: 7)
            }
            self?.updateGrass()
        }
    }
    
}

extension AppDelegate: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else {
            return
        }
        if window == settingsWC?.window {
            settingsWC = nil
        }
    }
    
}

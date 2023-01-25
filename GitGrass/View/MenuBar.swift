//
//  MenuBar.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import AppKit
import Combine

final class MenuBar<MM: MenuBarModel>: NSObject {
    private let statusItem = NSStatusItem.default
    private let menu = NSMenu()
    private let menuBarModel: MM
    private var cancellable: AnyCancellable?

    init(menuBarModel: MM) {
        self.menuBarModel = menuBarModel
        super.init()

        menu.addItem(title: "preferences".localized,
                     action: #selector(openPreferences(_:)),
                     target: self)
        menu.addSeparator()
        menu.addItem(title: "aboutGitGrass".localized,
                     action: #selector(openAbout(_:)),
                     target: self)
        menu.addItem(title: "quitGitGrass".localized,
                     action: #selector(terminateApp(_:)),
                     target: self)
        statusItem.menu = menu

        if let superview = statusItem.button?.superview {
            cancellable = superview
                .publisher(for: \.effectiveAppearance, options: .new)
                .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
                .removeDuplicates(by: { $0.isDark == $1.isDark })
                .sink { [weak self] _ in
                    self?.menuBarModel.updateAppearance()
                }
        }

        menuBarModel.updateImageHandler = { [weak self] (dayData, color, style, period) in
            guard let self else { return }
            DispatchQueue.main.async {
                self.statusItem.button?.image = NSImage(dayData: dayData,
                                                        color: color,
                                                        style: style,
                                                        period: period,
                                                        isDark: true)
            }
        }

//        NSImage(size: .zero, flipped: false) { rect in
//            if let superview = self.statusItem.button?.superview {
//                if superview.effectiveAppearance.isDark {
//                    NSImage().draw(in: rect)
//                } else {
//                    NSImage().draw(in: rect)
//                }
//            } else {
//                NSImage().draw(in: rect)
//            }
//            return true
//        }
    }

    @objc func openPreferences(_ sender: Any?) {
        menuBarModel.openPreferences()
    }

    @objc func openAbout(_ sender: Any?) {
        menuBarModel.openAbout()
    }

    @objc func terminateApp(_ sender: Any?) {
        menuBarModel.terminateApp()
    }
}

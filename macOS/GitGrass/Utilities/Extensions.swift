//
//  Extensions.swift
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

func logput(_ item: Any..., file: String = #file, line: Int = #line, function: String = #function) {
    #if DEBUG
    Swift.print("Log: \(file):Line\(line):\(function)", item)
    #endif
}

extension NSColor {
    static let url = NSColor(named: "urlColor")!
    
    static func fillColor(_ level: Int, _ color: Color, _ dark: Bool) -> NSColor {
        if color == .monochrome {
            let gray: CGFloat = dark ? 1.0 : 0.0
            switch level {
            case 0: return NSColor(white: gray, alpha: 0.2)
            case 1: return NSColor(white: gray, alpha: 0.4)
            case 2: return NSColor(white: gray, alpha: 0.6)
            case 3: return NSColor(white: gray, alpha: 0.8)
            case 4: return NSColor(white: gray, alpha: 1.0)
            default: fatalError("impossible")
            }
        } else {
            switch level {
            case 0: return NSColor(named: dark ? "grass5" : "grass0")!
            case 1: return NSColor(named: dark ? "grass4" : "grass1")!
            case 2: return NSColor(named: dark ? "grass3" : "grass2")!
            case 3: return NSColor(named: dark ? "grass2" : "grass3")!
            case 4: return NSColor(named: dark ? "grass1" : "grass4")!
            default: fatalError("impossible")
            }
        }
    }
}

extension String {
    func match(_ pattern: String) -> String? {
        guard
            let regex = try? NSRegularExpression(pattern: pattern),
            let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count))
            else { return nil }
        return NSString(string: self).substring(with: matched.range(at: 0))
    }

    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}

extension NSAppearance {
    var isDark: Bool {
        if self.name == .vibrantDark { return true }
        guard #available(macOS 10.14, *) else { return false }
        return self.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }
}


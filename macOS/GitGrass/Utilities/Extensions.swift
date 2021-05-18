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
            let grayColor: NSColor = dark ? .white : .black
            return grayColor.withAlphaComponent(0.2 * CGFloat(level + 1))
        } else if color == .greenGrass {
            let grassColor = NSColor(named: "\(dark ? "dark" : "light")-grass")!
            return grassColor.withAlphaComponent(0.2 * CGFloat(level + 1))
        } else {
            let accentColor = NSColor.controlAccentColor.usingColorSpace(NSColorSpace.deviceRGB)!
            return accentColor.withAlphaComponent(0.2 * CGFloat(level + 1))
        }
    }
}

extension String {
    func match(_ pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count))
        else { return [] }
        return (0 ..< matched.numberOfRanges).map {
            NSString(string: self).substring(with: matched.range(at: $0))
        }
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


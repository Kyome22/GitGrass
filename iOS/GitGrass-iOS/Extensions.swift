//
//  Extensions.swift
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

func logput(_ item: Any, file: String = #file, line: Int = #line, function: String = #function) {
    #if DEBUG
    Swift.print("Log: \(file):Line\(line):\(function)", item)
    #endif
}

extension String {
    
    func match(_ pattern: String) -> String? {
        guard
            let regex = try? NSRegularExpression(pattern: pattern),
            let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count))
            else { return nil }
        return NSString(string: self).substring(with: matched.range(at: 0))
    }
    
    func trim(_ before: String, _ after: String) -> String {
        let new = self.replacingOccurrences(of: before, with: "")
        return new.replacingOccurrences(of: after, with: "")
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
}

extension UIColor {
    
    static func grassColor(_ level: Int, _ color: Color, _ dark: Bool) -> UIColor {
        if color == .greenGrass {
            switch level {
            case 0: return UIColor(named: dark ? "grassDark0" : "grass0")!
            case 1: return UIColor(named: dark ? "grassDark1" : "grass1")!
            case 2: return UIColor(named: dark ? "grassDark2" : "grass2")!
            case 3: return UIColor(named: dark ? "grassDark3" : "grass3")!
            case 4: return UIColor(named: dark ? "grassDark4" : "grass4")!
            default: fatalError("impossible")
            }
        } else { // .monochrome
            let white: CGFloat = dark ? 1.0 : 0.0
            switch level {
            case 0: return UIColor(white: white, alpha: 0.2)
            case 1: return UIColor(white: white, alpha: 0.4)
            case 2: return UIColor(white: white, alpha: 0.6)
            case 3: return UIColor(white: white, alpha: 0.8)
            case 4: return UIColor(white: white, alpha: 1.0)
            default: fatalError("impossible")
            }
        }
    }
    
}

extension UITraitCollection {
    
    var isDark: Bool {
        return userInterfaceStyle == .dark
    }

}

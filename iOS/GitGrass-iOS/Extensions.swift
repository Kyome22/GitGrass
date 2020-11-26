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

func logput(_ items: Any...,
            file: String = #file,
            line: Int = #line,
            function: String = #function) {
    #if DEBUG
    let fileName = URL(fileURLWithPath: file).lastPathComponent
    Swift.print("💫Log: \(fileName), Line:\(line), \(function), [")
    items.forEach { (item) in
        Swift.print(item)
    }
    Swift.print("]")
    #endif
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

extension UIColor {
    // dark mode 対応してないので要らない
    static func grassColor(_ level: Int, _ color: GGColor) -> UIColor {
        if color == .monochrome {
            return UIColor(white: 0.0, alpha: 0.2 * CGFloat(level + 1))
        } else {
            return UIColor(named: "grass-\(level)")!
        }
    }
    
}

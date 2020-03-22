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
    
    static func grassColor(_ level: Int) -> UIColor {
        switch level {
        case 1: return UIColor(named: "grass25")!
        case 2: return UIColor(named: "grass50")!
        case 3: return UIColor(named: "grass75")!
        case 4: return UIColor(named: "grass100")!
        default: return UIColor(named: "grass0")!
        }
    }
    
}

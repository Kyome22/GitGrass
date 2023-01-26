//
//  String+Extensions.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2022/10/11.
//  Copyright 2022 Takuto Nakamura
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

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }

    func match(_ pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count))
        else { return [] }
        return (0 ..< matched.numberOfRanges).map {
            NSString(string: self).substring(with: matched.range(at: $0))
        }
    }

//    func match(_ pattern: String) -> [String] {
//        let range = NSRange(location: 0, length: self.count)
//        guard let regex = try? NSRegularExpression(pattern: pattern),
//              let matched = regex.firstMatch(in: self, range: range)
//        else { return [] }
//        return (0 ..< matched.numberOfRanges).compactMap { i in
//            let r = matched.range(at: i)
//            if r.location == NSNotFound { return nil }
//            return NSString(string: self).substring(with: r)
//        }
//    }
}

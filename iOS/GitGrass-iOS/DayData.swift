//
//  DayData.swift
//  GitGrass-iOS
//
//  Created by Takuto Nakamura on 2020/03/23.
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

import Foundation

class DayData: NSObject, NSCoding, NSSecureCoding {

    static var supportsSecureCoding: Bool {
        return true
    }
    
    static let `default` = [[DayData]](repeating: [DayData](repeating: DayData(0, 0), count: 53), count: 7)
    
    let level: Int
    let count: Int
    
    override var description: String {
        return "level: \(level) count: \(count)"
    }
    
    init(_ level: Int, _ count: Int) {
        self.level = level
        self.count = count
    }
    
    required init?(coder: NSCoder) {
        level = coder.decodeInteger(forKey: "level")
        count = coder.decodeInteger(forKey: "count")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(level, forKey: "level")
        coder.encode(count, forKey: "count")
    }
    
}

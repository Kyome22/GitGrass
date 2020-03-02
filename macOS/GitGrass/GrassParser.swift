//
//  GrassParser.swift
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

struct DayData {
    let level: Int
    let count: Int
    let date: String
    var description: String {
        return "level: \(level) count: \(count) date: \(date)"
    }
    static let `default` = [[DayData]](repeating: [DayData](repeating: DayData(level: 0, count: 0, date: "dummy"), count: 50), count: 7)
}

class GrassParser {
    
    static func parse(html: String) -> [[DayData]] {
        var tags = html.components(separatedBy: .newlines)
        tags = tags.compactMap({ (str) -> String? in
            let res = str.trimmingCharacters(in: .whitespaces)
            if res.hasPrefix("<rect") {
                return res
            }
            return nil
        })
        var dayData: [[DayData]] = [[], [], [], [], [], [], []]
        tags.forEach { (str) in
            let parameter = str.components(separatedBy: " ")
            let y = Int(parameter[5].trim("y=\"", "\""))! / 15
            let level: Int
            switch parameter[6].trim("fill=\"", "\"") {
            case "#ebedf0": level = 0
            case "#c6e48b": level = 1
            case "#7bc96f": level = 2
            case "#239a3b": level = 3
            case "#196127": level = 4
            default: level = 0
            }
            dayData[y].append(DayData(level: level,
                                      count: Int(parameter[7].trim("data-count=\"", "\""))!,
                                      date: parameter[8].trim("data-date=\"", "\"/>")))
        }
        return dayData
    }
    
}

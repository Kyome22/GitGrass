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

    static let `default` = [[DayData]](repeating: [DayData](repeating: DayData(0, 0, "dummy"), count: 50), count: 7)

    init(_ level: Int, _ count: Int, _ date: String) {
        self.level = level
        self.count = count
        self.date = date
    }

}

class GrassParser {
    
    static func parse(html: String) -> [[DayData]] {
        var tags = html.components(separatedBy: .newlines)
        tags = tags.compactMap({ (str) -> String? in
            let res = str.trimmingCharacters(in: .whitespaces)
            return res.match("<rect class=\"day\".+(/>|></rect>)")
        })
        var dayData = [[DayData]](repeating: [], count: 7)
        for i in (0 ..< tags.count) {
            let params = tags[i]
                .components(separatedBy: " ")
                .compactMap { (str) -> (key: String, value: String)? in
                    if str.contains("=") {
                        let array = str.components(separatedBy: "=")
                        return (array[0], array[1])
                    }
                    return nil
            }
            var dict = [String : String]()
            params.forEach { (param) in
                dict[param.key] = param.value.replacingOccurrences(of: "\"", with: "")
            }
            let level: Int
            switch dict["fill"] {
            case "#ebedf0": level = 0
            case "#c6e48b": level = 1
            case "#7bc96f": level = 2
            case "#239a3b": level = 3
            case "#196127": level = 4
            default: level = 0
            }
            let count = Int(dict["data-count"] ?? "0") ?? 0
            let date = dict["data-date"] ?? ""
            dayData[i % 7].append(DayData(level, count, date))
        }
        return dayData
    }
    
}

//
//  GrassParser.swift
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

class GrassParser {
    
    static func parse(html: String) -> [[DayData]] {
        let tags = html.components(separatedBy: .newlines)

        // capture the color of levels
        let levels = tags.compactMap({ (str) -> String? in
            return str.trimmingCharacters(in: .whitespaces)
                .match(#"<li style="background-color: var\([^)]+\)"#)?
                .match(#"var\([^)]+\)"#)
        })

        // extruct the day line
        let rects = tags.compactMap({ (str) -> String? in
            let res = str.trimmingCharacters(in: .whitespaces)
            return res.match(#"<rect class="day".+"#)
        }).map({ (str) -> String in
            let range = str.range(of: str)
            return str.replacingOccurrences(of: #"<rect|"|/>|></rect>"#,
                                            with: "",
                                            options: .regularExpression,
                                            range: range)
        })

        // tidy the day data
        var dayData = [[DayData]](repeating: [], count: 7)
        for i in (0 ..< rects.count) {
            let params = rects[i]
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: " ")
                .map({ (str) -> (key: String, value: String) in
                    let array = str.components(separatedBy: "=")
                    return (array[0], array[1])
                })
            var dict = [String : String]()
            params.forEach { (param) in
                dict[param.key] = param.value
            }
            let level = levels.firstIndex(of: dict["fill"] ?? "") ?? 0
            let count = Int(dict["data-count"] ?? "0") ?? 0
            dayData[i % 7].append(DayData(level, count))
        }
        return dayData
    }
    
}


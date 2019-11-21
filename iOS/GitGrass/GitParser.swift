//
//  GitParser.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/21.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

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

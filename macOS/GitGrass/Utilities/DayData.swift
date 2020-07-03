//
//  DayData.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2020/07/04.
//  Copyright © 2020 Takuto Nakamura. All rights reserved.
//

import Foundation

struct DayData {

    private static let line = [DayData](repeating: DayData(0, 0, "dummy"), count: 53)
    static let `default` = [[DayData]](repeating: DayData.line, count: 7)

    let level: Int
    let count: Int
    let date: String

    var description: String {
        return "level: \(level) count: \(count) date: \(date)"
    }

    init(_ level: Int, _ count: Int, _ date: String) {
        self.level = level
        self.count = count
        self.date = date
    }

}

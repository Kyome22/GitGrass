//
//  DayData.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/21.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

struct DayData {
    let level: Int
    let count: Int
    let date: String
    
    var description: String {
        return "level: \(level) count: \(count) date: \(date)"
    }
}

/*
  DayData.swift
  GitGrass

  Created by Takuto Nakamura on 2022/10/11.
  Copyright 2022 Takuto Nakamura

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import Foundation

struct DayData {
    private static let week = [DayData](repeating: DayData(0, 0, ""), count: 7)
    static let `default` = [[DayData]](repeating: DayData.week, count: 53)

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

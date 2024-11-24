/*
 DayData.swift
 DataLayer

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

public struct DayData: Sendable, Equatable, CustomStringConvertible {
    private static let empty = DayData(level: .zero, count: .zero, date: "")
    private static let week = [DayData](repeating: DayData.empty, count: 7)
    public static let `default` = [[DayData]](repeating: DayData.week, count: 53)

    public var level: Int
    public var count: Int
    public var date: String

    public var description: String {
        "level: \(level) count: \(count) date: \(date)"
    }

    public init(level: Int, count: Int, date: String) {
        self.level = level
        self.count = count
        self.date = date
    }
}

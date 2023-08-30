/*
 ContributionsOutput.swift
 GitGrass

 Created by Takuto Nakamura on 2023/08/30.
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

struct ContributionsOutput: Decodable {
    enum ContributionLevel: String, Decodable {
        case firstQuartile = "FIRST_QUARTILE"
        case secondQuartile = "SECOND_QUARTILE"
        case thirdQuartile = "THIRD_QUARTILE"
        case fourthQuartile = "FOURTH_QUARTILE"
        case none = "NONE"

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = type(of: self).init(rawValue: rawValue) ?? .none
        }
    }

    struct Day: Decodable {
        let contributionLevel: ContributionLevel
        let contributionCount: Int
        let date: String
    }

    struct Week: Decodable {
        let contributionDays: [Day]
    }

    struct ContributionCalendar: Decodable {
        let totalContributions: Int
        let weeks: [Week]
    }

    struct ContributionsCollection: Decodable {
        let contributionCalendar: ContributionCalendar
    }

    struct User: Decodable {
        let contributionsCollection: ContributionsCollection
    }

    let user: User
}

extension ContributionsOutput {
    static var dummy: ContributionsOutput {
        let weeks = (0 ..< 53).map { _ in
            let days = (0 ..< 7).map { _ in
                return Day(contributionLevel: .none, contributionCount: 0, date: "")
            }
            return Week(contributionDays: days)
        }
        let calendar = ContributionCalendar(totalContributions: 53, weeks: weeks)
        let collection = ContributionsCollection(contributionCalendar: calendar)
        return ContributionsOutput(user: User(contributionsCollection: collection))
    }
}

extension ContributionsOutput.ContributionLevel {
    var integer: Int {
        switch self {
        case .firstQuartile:    return 4
        case .secondQuartile:   return 3
        case .thirdQuartile:    return 2
        case .fourthQuartile:   return 1
        case .none:             return 0
        }
    }
}

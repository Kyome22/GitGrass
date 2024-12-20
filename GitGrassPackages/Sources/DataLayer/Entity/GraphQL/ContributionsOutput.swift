/*
 ContributionsOutput.swift
 DataLayer

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

struct ContributionsData: Decodable, Sendable {
    var user: GitHubUser?
}

public struct GitHubUser: Decodable, Sendable {
    public var contributionsCollection: ContributionsCollection

    public struct ContributionsCollection: Decodable, Sendable {
        public var contributionCalendar: ContributionCalendar
    }

    public struct ContributionCalendar: Decodable, Sendable {
        public var totalContributions: Int
        public var weeks: [Week]
    }

    public struct Week: Decodable, Sendable {
        public var contributionDays: [Day]
    }

    public struct Day: Decodable, Sendable {
        public var contributionLevel: ContributionLevel
        public var contributionCount: Int
        public var date: String
    }

    public enum ContributionLevel: String, Decodable, Sendable {
        case firstQuartile = "FIRST_QUARTILE"
        case secondQuartile = "SECOND_QUARTILE"
        case thirdQuartile = "THIRD_QUARTILE"
        case fourthQuartile = "FOURTH_QUARTILE"
        case none = "NONE"

        public var integer: Int {
            switch self {
            case .firstQuartile:  4
            case .secondQuartile: 3
            case .thirdQuartile:  2
            case .fourthQuartile: 1
            case .none:           0
            }
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = type(of: self).init(rawValue: rawValue) ?? .none
        }
    }
}

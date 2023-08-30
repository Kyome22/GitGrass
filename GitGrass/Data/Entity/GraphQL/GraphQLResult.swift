/*
 GraphQLResult.swift
 GitGrass

 Created by Takuto Nakamura on 2023/08/30.
 Copyright 2023 Takuto Nakamura

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

struct GraphQLResult: Decodable {
    let output: ContributionsOutput?
    let errorMessages: [String]

    enum CodingKeys: String, CodingKey {
        case data
        case errors
    }

    struct GraphQLError: Decodable {
        let message: String
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.output = try container.decodeIfPresent(ContributionsOutput.self, forKey: .data)

        var errorMessages = [String]()
        if let errors = try container.decodeIfPresent([GraphQLError].self, forKey: .errors) {
            errorMessages = errors.map { $0.message }
        }
        self.errorMessages = errorMessages
    }
}

/*
 ContributionRepository.swift
 DataLayer

 Created by Takuto Nakamura on 2024/11/24.
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

public struct ContributionRepository: Sendable {
    private var urlSessionClient: URLSessionClient

    public init(_ urlSessionClient: URLSessionClient) {
        self.urlSessionClient = urlSessionClient
    }

    public func getGrass(token: String, username: String) async throws -> ContributionsOutput {
        let body = GraphQLBody(
            input: UserNameInput(userName: username),
            queryString: """
            query($userName: String!) {
                user(login: $userName){
                    contributionsCollection {
                        contributionCalendar {
                            totalContributions
                            weeks {
                                contributionDays {
                                    contributionLevel
                                    contributionCount
                                    date
                                }
                            }
                        }
                    }
                }
            }
            """
        )
        let url = URL(string: "https://api.github.com/graphql")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await urlSessionClient.data(request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OperationError.responseError
        }
        let result = try JSONDecoder().decode(GraphQLResult.self, from: data)
        guard result.errorMessages.isEmpty, let output = result.output else {
            throw OperationError.decodingError(result.errorMessages)
        }
        return output
    }

    public enum OperationError: Error {
        case responseError
        case decodingError([String])
    }
}

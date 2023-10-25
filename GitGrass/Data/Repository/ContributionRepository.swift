/*
 ContributionRepository.swift
 GitGrass

 Created by Takuto Nakamura on 2023/01/26.
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

protocol ContributionRepository: AnyObject {
    init()

    // rate limit: 5000 points per hour
    func getGrass(_ token: String, _ username: String) async throws -> ContributionsOutput
}

final class ContributionRepositoryImpl: ContributionRepository {
    func getGrass(_ token: String, _ username: String) async throws -> ContributionsOutput {
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
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GitGrassError.responseError
        }
        let result = try JSONDecoder().decode(GraphQLResult.self, from: data)
        if result.errorMessages.isEmpty, let output = result.output {
            return output
        } else {
            result.errorMessages.forEach { error in
                logput(error)
            }
            throw GitGrassError.graphqlReturnedErrorMessages
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ContributionRepositoryMock: ContributionRepository {
        func getGrass(_ token: String, _ username: String) async throws -> ContributionsOutput { .dummy }
    }
}

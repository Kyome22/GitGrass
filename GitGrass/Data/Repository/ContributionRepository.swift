//
//  ContributionRepository.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/26.
//  Copyright 2023 Takuto Nakamura
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

protocol ContributionRepository: AnyObject {
    init()

    func getGrass(username: String) async throws -> String
    func getDummyGrass(username: String) async throws -> String
}

final class ContributionRepositoryImpl: ContributionRepository {
    func getGrass(username: String) async throws -> String {
        let urlString = "https://github.com/users/\(username)/contributions"
        guard let url = URL(string: urlString) else {
            throw GitGrassError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitGrassError.responseError
        }
        if httpResponse.statusCode == 200, let text = String(data: data, encoding: .utf8) {
            return text
        }
        throw GitGrassError.badStatus
    }

    func getDummyGrass(username: String) async throws -> String {
        if let url = Bundle.main.url(forResource: "dummy", withExtension: "html") {
            return try String(contentsOf: url, encoding: .utf8)
        }
        throw GitGrassError.invalidURL
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ContributionRepositoryMock: ContributionRepository {
        func getGrass(username: String) async throws -> String { "" }
        func getDummyGrass(username: String) async throws -> String { "" }
    }
}

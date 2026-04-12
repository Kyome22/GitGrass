import Foundation
import Testing

@testable import DataSource

struct ContributionRepositoryTests {
    @Test
    func fetchContributions_success() async throws {
        let urlSessionClient = testDependency(of: URLSessionClient.self) {
            $0.data = { request in
                let data = try! JSONEncoder().encode(GraphQLResult(
                    user: .init(
                        contributionsCollection: .init(
                            contributionCalendar: .init(
                                totalContributions: 0,
                                weeks: []
                            )
                        )
                    )
                ))
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (data, response)
            }
        }
        let sut = ContributionRepository(urlSessionClient)
        let actual = try await sut.fetchContributions(token: "", username: "")
        #expect(actual == .init(
            contributionsCollection: .init(
                contributionCalendar: .init(
                    totalContributions: 0,
                    weeks: []
                )
            )
        ))
    }

    @Test
    func fetchContributions_failure_bad_request() async {
        let urlSessionClient = testDependency(of: URLSessionClient.self) {
            $0.data = { _ in
                throw URLError(.badServerResponse)
            }
        }
        let sut = ContributionRepository(urlSessionClient)
        await #expect(throws: URLError(.badServerResponse)) {
            try await sut.fetchContributions(token: "", username: "")
        }
    }

    @Test
    func fetchContributions_failure_bad_statusCode() async {
        let urlSessionClient = testDependency(of: URLSessionClient.self) {
            $0.data = { request in
                let data = try! JSONEncoder().encode(GraphQLResult())
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 400,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (data, response)
            }
        }
        let sut = ContributionRepository(urlSessionClient)
        await #expect(throws: ContributionRepository.OperationError.invalidResponse) {
            try await sut.fetchContributions(token: "", username: "")
        }
    }

    @Test
    func fetchContributions_failure_broken_object() async {
        let urlSessionClient = testDependency(of: URLSessionClient.self) {
            $0.data = { request in
                let data = try! JSONEncoder().encode(GraphQLResult())
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (data, response)
            }
        }
        let sut = ContributionRepository(urlSessionClient)
        await #expect(throws: ContributionRepository.OperationError.decodeFailed) {
            try await sut.fetchContributions(token: "", username: "")
        }
    }

    @Test
    func fetchContributions_failure_account_not_found() async {
        let urlSessionClient = testDependency(of: URLSessionClient.self) {
            $0.data = { request in
                let data = try! JSONEncoder().encode(GraphQLResult(
                    errors: [
                        .init(type: "NOT_FOUND", message: ""),
                    ]
                ))
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (data, response)
            }
        }
        let sut = ContributionRepository(urlSessionClient)
        await #expect(throws: ContributionRepository.OperationError.gitHubAccountNotFound) {
            try await sut.fetchContributions(token: "", username: "")
        }
    }

    @Test
    func fetchContributions_failure_uncategorized_errors_occurred() async {
        let urlSessionClient = testDependency(of: URLSessionClient.self) {
            $0.data = { request in
                let data = try! JSONEncoder().encode(GraphQLResult(
                    errors: [
                        .init(type: "type1", message: "message1"),
                        .init(type: "type2", message: "message2"),
                    ]
                ))
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (data, response)
            }
        }
        let sut = ContributionRepository(urlSessionClient)
        await #expect(throws: ContributionRepository.OperationError.uncategorizedErrorsOccurred(["message1", "message2"])) {
            try await sut.fetchContributions(token: "", username: "")
        }
    }
}

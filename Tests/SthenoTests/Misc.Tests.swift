import Foundation
import Testing

@testable import Stheno

@Suite("Misc Utility")
struct MiscTests {
    @Test func `example.com contains 'Example Domain'`() async throws {
        let url = try #require(URL(string: "https://example.com"), "URL should be valid")

        do {
            let string = try await fetchString(using: url)
            let containsDomain = string.range(of: "Example Domain", options: .caseInsensitive) != nil
            #expect(containsDomain, "Expected the response from example.com to contain 'Example Domain'.")
            return
        } catch {
        }
    }

    // Helper to bridge the completion API to async/await.
    private func fetchString(using url: URL) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            downloadURLAsString(from: url) { result in
                switch result {
                case let .success(string):
                    continuation.resume(returning: string)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

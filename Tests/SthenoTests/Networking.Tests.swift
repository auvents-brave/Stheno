import Foundation
import Testing

@testable import Stheno

#if canImport(Darwin) || canImport(FoundationNetworking)  // not for os(WASI)
	@Suite("Networking")
	struct NetworkingTests {
		@Test func `example.com contains 'Example Domain'`() async throws {
			let url = try #require(URL(string: "http://example.com"), "URL should be valid")  // https failed on Android

			let string = try await fetchString(using: url)
			let containsDomain = string.range(of: "Example Domain", options: .caseInsensitive) != nil
			#expect(containsDomain, "Expected the response from example.com to contain 'Example Domain'.")
		}

		@Test func `An unreachable host fails with a transport error`() async throws {
			// `.invalid` never resolves (RFC 2606), so this hits the transport-error
			// branch without depending on a live server.
			let url = try #require(URL(string: "http://no-such-host.invalid"))
			await #expect(throws: (any Error).self) {
				_ = try await fetchString(using: url)
			}
		}

		// Helper to bridge the completion API to async/await.
		private func fetchString(using url: URL) async throws -> String {
			try await withCheckedThrowingContinuation { continuation in
				downloadURLasString(from: url) { result in
					switch result {
					case .success(let string):
						continuation.resume(returning: string)
					case .failure(let error):
						continuation.resume(throwing: error)
					}
				}
			}
		}
	}
#endif

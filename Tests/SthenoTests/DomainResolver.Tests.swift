import Foundation
import Testing

@testable import Stheno

// Mirrors the source guard: the resolver only exists where the system C
// networking symbols are in scope (Darwin, Glibc, WinSDK) — the SonarCloud
// Ubuntu runner builds the Glibc path.
#if canImport(Darwin) || canImport(Glibc) || canImport(WinSDK)

	@Suite("DomainResolver")
	struct DomainResolverTests {
		@Test func `Resolves localhost to a loopback address`() async throws {
			let addresses = try await DomainResolver.resolve("localhost")
			#expect(!addresses.isEmpty)
			// IPv6 may be disabled on a runner, so accept either loopback form.
			#expect(addresses.contains { $0 == "127.0.0.1" || $0 == "::1" })
		}

		@Test func `An unresolvable host throws a ResolveError`() async {
			// `.invalid` is reserved (RFC 2606) and never resolves — no network needed.
			await #expect(throws: DomainResolver.ResolveError.self) {
				_ = try await DomainResolver.resolve("no-such-host.invalid")
			}
		}

		@Test func `The resolve error carries a human-readable description`() {
			let error = DomainResolver.ResolveError.failed("boom")
			#expect(error.errorDescription?.contains("boom") == true)
		}

		@Test func `resolveIPv4 returns the loopback address for localhost`() async throws {
			let address = try await DomainResolver.resolveIPv4("localhost")
			#expect(address == "127.0.0.1")
		}

		@Test func `resolveIPv6 returns an address or nil without throwing`() async throws {
			// IPv6 may be disabled on a runner, so the result can be nil; the point
			// is to cover the convenience method and confirm it filters to a
			// colon-bearing address when one is present.
			let address = try await DomainResolver.resolveIPv6("localhost")
			if let address { #expect(address.contains(":")) }
		}
	}

#endif

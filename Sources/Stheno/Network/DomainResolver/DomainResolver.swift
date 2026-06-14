// The system resolver (`getaddrinfo`) is wired up on Darwin, Linux (Glibc) and
// Windows (WinSDK) only. On Android (Bionic) and WASI the C networking symbols
// aren't in scope, so the whole type is excluded there.
//
// This file holds the cross-platform surface; each platform's `blockingResolve`
// lives in its own `DomainResolver+<Platform>.swift`. That split lets the Mac
// and Windows variants — which never compile on the SonarCloud Linux runner —
// be dropped from the coverage metric without hiding the Linux path.
#if canImport(Darwin) || canImport(Glibc) || canImport(WinSDK)

	public import Foundation

	/// Resolves a hostname to its IP addresses using the system resolver (`getaddrinfo`).
	///
	/// Works on Darwin, Linux and Windows. Runs the blocking syscall on a detached
	/// task to avoid blocking the calling actor.
	///
	/// ```swift
	/// let addresses = try await DomainResolver.resolve("example.com")
	/// // ["93.184.216.34", "2606:2800:21f:cb07:6820:80da:af6b:8b2c"]
	/// ```
	public enum DomainResolver {
		/// Errors thrown during resolution.
		public enum ResolveError: Error, LocalizedError {
			/// The hostname could not be resolved.
			case failed(String)

			public var errorDescription: String? {
				switch self {
				case .failed(let msg): "Domain resolution failed: \(msg)"
				}
			}
		}

		/// Resolves `hostname` and returns all IP addresses (IPv4 and IPv6).
		///
		/// - Parameter hostname: A domain name such as `"example.com"`.
		/// - Returns: An array of IP address strings (may mix IPv4 and IPv6).
		/// - Throws: ``ResolveError/failed(_:)`` when `getaddrinfo` returns an error.
		public static func resolve(_ hostname: String) async throws -> [String] {
			// Run the blocking `getaddrinfo` lookup (platform-specific) off the
			// calling actor.
			try await Task.detached(priority: .userInitiated) {
				try blockingResolve(hostname)
			}.value
		}

		/// Resolves `hostname` and returns only the first IPv4 address, if any.
		public static func resolveIPv4(_ hostname: String) async throws -> String? {
			try await resolve(hostname).first { $0.contains(".") }
		}

		/// Resolves `hostname` and returns only the first IPv6 address, if any.
		public static func resolveIPv6(_ hostname: String) async throws -> String? {
			try await resolve(hostname).first { $0.contains(":") }
		}
	}

#endif

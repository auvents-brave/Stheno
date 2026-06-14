// The system resolver (`getaddrinfo`) is wired up on Darwin, Linux (Glibc) and
// Windows (WinSDK) only. On Android (Bionic) and WASI the C networking symbols
// aren't in scope, so the whole type is excluded there.
//
// This file holds the cross-platform surface and the shared address-collection
// loop; each platform's `blockingResolve` lives in its own
// `DomainResolver+<Platform>.swift` (`+POSIX` for Darwin & Linux, `+Windows`).
// The Windows variant never compiles on the SonarCloud Linux runner, so it is
// dropped from the coverage metric without hiding the POSIX path.
#if canImport(Darwin) || canImport(Glibc) || canImport(WinSDK)

	public import Foundation

	#if canImport(Darwin)
		import Darwin
	#elseif canImport(Glibc)
		import Glibc
	#elseif canImport(WinSDK)
		import WinSDK
	#endif

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

		/// Collects the unique numeric IP strings from a resolved `getaddrinfo`
		/// list, shared by every platform's `blockingResolve`. Only the
		/// `getnameinfo` argument types differ between Windows and the POSIX
		/// platforms, so that one call is gated; the rest of the walk is common.
		static func addresses(from head: UnsafeMutablePointer<addrinfo>) -> [String] {
			var addresses: [String] = []
			var cursor: UnsafeMutablePointer<addrinfo>? = head
			while let node = cursor {
				var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
				#if canImport(WinSDK)
					// On Windows the buffer size is `DWORD` and the address length must
					// be cast to `socklen_t`.
					let resolved =
						getnameinfo(
							node.pointee.ai_addr, socklen_t(node.pointee.ai_addrlen),
							&host, DWORD(NI_MAXHOST), nil, 0, NI_NUMERICHOST
						) == 0
				#else
					let resolved =
						getnameinfo(
							node.pointee.ai_addr, node.pointee.ai_addrlen,
							&host, socklen_t(NI_MAXHOST), nil, 0, NI_NUMERICHOST
						) == 0
				#endif
				if resolved {
					let addr = String(
						decoding: host.prefix(while: { $0 != 0 }).map(UInt8.init(bitPattern:)),
						as: UTF8.self
					)
					if !addresses.contains(addr) { addresses.append(addr) }
				}
				cursor = node.pointee.ai_next
			}
			return addresses
		}
	}

#endif

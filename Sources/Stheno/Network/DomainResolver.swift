// The system resolver (`getaddrinfo`) is wired up on Darwin, Linux (Glibc) and
// Windows (WinSDK) only. On Android (Bionic) and WASI the C networking symbols
// aren't in scope, so the whole type is excluded there.
#if canImport(Darwin) || canImport(Glibc) || canImport(WinSDK)

	#if canImport(Darwin)
		import Darwin
	#elseif canImport(Glibc)
		import Glibc
	#elseif canImport(WinSDK)
		import WinSDK
	#endif

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

		#if canImport(WinSDK)
			/// Winsock must be initialised once before any `getaddrinfo` call on Windows.
			private static let winsockReady: Bool = {
				var data = WSADATA()
				return WSAStartup(WORD(0x0202), &data) == 0  // request Winsock 2.2
			}()
		#endif

		/// Resolves `hostname` and returns all IP addresses (IPv4 and IPv6).
		///
		/// - Parameter hostname: A domain name such as `"example.com"`.
		/// - Returns: An array of IP address strings (may mix IPv4 and IPv6).
		/// - Throws: ``ResolveError/failed(_:)`` when `getaddrinfo` returns an error.
		public static func resolve(_ hostname: String) async throws -> [String] {
			// Run the blocking `getaddrinfo` lookup off the calling actor.
			try await Task.detached(priority: .userInitiated) {
				try blockingResolve(hostname)
			}.value
		}

		/// The blocking `getaddrinfo` lookup. Synchronous and throwing; invoked from
		/// a detached task by ``resolve(_:)`` so it never blocks the caller.
		private static func blockingResolve(_ hostname: String) throws -> [String] {
			#if canImport(WinSDK)
				guard winsockReady else {
					throw ResolveError.failed("Winsock initialisation failed (WSAStartup).")
				}
			#endif

			var hints = addrinfo()
			hints.ai_family = AF_UNSPEC
			// On Glibc, `SOCK_STREAM` is the `__socket_type` enum, not the
			// `Int32` that `ai_socktype` expects (it is `Int32` on Darwin/WinSDK).
			#if canImport(Glibc)
				hints.ai_socktype = Int32(SOCK_STREAM.rawValue)
			#else
				hints.ai_socktype = SOCK_STREAM
			#endif

			var result: UnsafeMutablePointer<addrinfo>?
			let status = getaddrinfo(hostname, nil, &hints, &result)
			guard status == 0, let head = result else {
				throw ResolveError.failed(message(for: status))
			}
			defer { freeaddrinfo(result) }

			var addresses: [String] = []
			var cursor: UnsafeMutablePointer<addrinfo>? = head
			while let node = cursor {
				var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
				// `getnameinfo` buffer-size parameter is `DWORD` on Windows
				// and `socklen_t` elsewhere; the address length differs too.
				#if canImport(WinSDK)
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

		/// Human-readable message for a `getaddrinfo` error code.
		private static func message(for status: Int32) -> String {
			#if canImport(WinSDK)
				// `gai_strerror` is a macro on Windows and cannot be called from Swift;
				// report the raw WSA error code instead.
				return "getaddrinfo failed (code \(status))"
			#else
				return String(cString: gai_strerror(status))
			#endif
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

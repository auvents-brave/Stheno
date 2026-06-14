// Windows (WinSDK) implementation of the `getaddrinfo` lookup. Excluded from the
// SonarCloud coverage metric: it never compiles on the Linux runner, so its
// lines would otherwise read as uncovered.
#if canImport(WinSDK)

	import WinSDK

	extension DomainResolver {
		/// Winsock must be initialised once before any `getaddrinfo` call on Windows.
		private static let winsockReady: Bool = {
			var data = WSADATA()
			return WSAStartup(WORD(0x0202), &data) == 0  // request Winsock 2.2
		}()

		/// The blocking `getaddrinfo` lookup on Windows. Synchronous and throwing;
		/// invoked from a detached task by ``resolve(_:)``.
		static func blockingResolve(_ hostname: String) throws -> [String] {
			guard winsockReady else {
				throw ResolveError.failed("Winsock initialisation failed (WSAStartup).")
			}

			var hints = addrinfo()
			hints.ai_family = AF_UNSPEC
			hints.ai_socktype = SOCK_STREAM

			var result: UnsafeMutablePointer<addrinfo>?
			let status = getaddrinfo(hostname, nil, &hints, &result)
			guard status == 0, let head = result else {
				throw ResolveError.failed(message(for: status))
			}
			defer { freeaddrinfo(result) }
			return addresses(from: head)
		}

		/// Human-readable message for a `getaddrinfo` error code.
		///
		/// `gai_strerror` is a macro on Windows and cannot be called from Swift, so
		/// we report the raw WSA error code instead.
		private static func message(for status: Int32) -> String {
			"getaddrinfo failed (code \(status))"
		}
	}

#endif

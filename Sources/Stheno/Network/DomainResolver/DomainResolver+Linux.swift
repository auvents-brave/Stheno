// Linux (Glibc) implementation of the `getaddrinfo` lookup. This is the variant
// the SonarCloud Ubuntu runner compiles and exercises, so it stays in the
// coverage metric.
#if canImport(Glibc)

	import Glibc

	extension DomainResolver {
		/// The blocking `getaddrinfo` lookup on Linux. Synchronous and throwing;
		/// invoked from a detached task by ``resolve(_:)``.
		static func blockingResolve(_ hostname: String) throws -> [String] {
			var hints = addrinfo()
			hints.ai_family = AF_UNSPEC
			// On Glibc, `SOCK_STREAM` is the `__socket_type` enum, not the `Int32`
			// that `ai_socktype` expects (it is `Int32` on Darwin/WinSDK).
			hints.ai_socktype = Int32(SOCK_STREAM.rawValue)

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
				let resolved =
					getnameinfo(
						node.pointee.ai_addr, node.pointee.ai_addrlen,
						&host, socklen_t(NI_MAXHOST), nil, 0, NI_NUMERICHOST
					) == 0
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
			String(cString: gai_strerror(status))
		}
	}

#endif

// Darwin (iOS / macOS / watchOS / tvOS / visionOS) implementation of the
// `getaddrinfo` lookup. Excluded from the SonarCloud coverage metric: it never
// compiles on the Linux runner, so its lines would otherwise read as uncovered.
#if canImport(Darwin)

	import Darwin

	extension DomainResolver {
		/// The blocking `getaddrinfo` lookup on Darwin. Synchronous and throwing;
		/// invoked from a detached task by ``resolve(_:)``.
		static func blockingResolve(_ hostname: String) throws -> [String] {
			var hints = addrinfo()
			hints.ai_family = AF_UNSPEC
			hints.ai_socktype = SOCK_STREAM

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

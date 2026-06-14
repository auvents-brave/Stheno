// POSIX (Darwin + Glibc) implementation of the `getaddrinfo` lookup, shared by
// the Apple platforms and Linux — they expose the same C API with only a small
// `ai_socktype` type difference. This is the variant the SonarCloud Ubuntu
// runner compiles and exercises (via Glibc), so it stays in the coverage metric.
#if canImport(Darwin) || canImport(Glibc)

	#if canImport(Darwin)
		import Darwin
	#elseif canImport(Glibc)
		import Glibc
	#endif

	extension DomainResolver {
		/// The blocking `getaddrinfo` lookup on Darwin and Linux. Synchronous and
		/// throwing; invoked from a detached task by ``resolve(_:)``.
		static func blockingResolve(_ hostname: String) throws -> [String] {
			var hints = addrinfo()
			hints.ai_family = AF_UNSPEC
			#if canImport(Glibc)
				// On Glibc, `SOCK_STREAM` is the `__socket_type` enum, not the `Int32`
				// that `ai_socktype` expects (it is `Int32` on Darwin).
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
			return addresses(from: head)
		}

		/// Human-readable message for a `getaddrinfo` error code.
		private static func message(for status: Int32) -> String {
			String(cString: gai_strerror(status))
		}
	}

#endif

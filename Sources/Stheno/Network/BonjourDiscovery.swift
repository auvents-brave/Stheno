// MARK: - BonjourDiscoveryError

/// Error thrown by ``BonjourDiscovery`` when the platform back-end cannot be initialised.
public struct BonjourDiscoveryError: Error, CustomStringConvertible {
	/// A human-readable description of the failure.
	public let description: String
	/// Creates an error carrying the given message.
	public init(_ message: String) { self.description = message }
}

// MARK: - DiscoveredEndpoint

/// A Bonjour service type to browse, together with the connection parameters to
/// apply once a matching instance is resolved.
///
/// ``BonjourDiscovery`` is not tied to any particular protocol family.
/// Pass whatever Bonjour types you need — The struct carries everything needed to
/// open a connection: ``host``, ``port``, ``path``, and the ready-to-use ``url``.
///
/// ## Example — VNC server
///
/// VNC servers advertise under `_rfb._tcp` (Remote Frame Buffer).
/// The `vnc://` scheme lets most VNC clients open the URL directly.
///
/// ```swift
/// let vnc = BonjourServiceEntry(
///     bonjourType: "_rfb._tcp",
///     scheme:      "vnc",
///     label:       "vnc"
/// )
/// // endpoint.url → "vnc://192.168.1.10:5900"
/// ```
///
/// ## Example — IPP printer
///
/// IPP printers advertise under `_ipp._tcp` on port 631.
///
/// ```swift
/// let ipp = BonjourServiceEntry(
///     bonjourType: "_ipp._tcp",
///     scheme:      "ipp",
///     label:       "printer-ipp"
/// )
/// // endpoint.url → "ipp://192.168.1.42:631"
/// ```
///
/// ## Example — file servers (SMB and FTP)
///
/// ```swift
/// let smb = BonjourServiceEntry(bonjourType: "_smb._tcp", scheme: "smb", label: "file-smb")
/// let ftp = BonjourServiceEntry(bonjourType: "_ftp._tcp", scheme: "ftp", label: "file-ftp")
/// // endpoint.url → "smb://192.168.1.3:445"  /  "ftp://192.168.1.3:21"
/// ```
///
/// ## Browsing a custom list
///
/// ```swift
/// let types = [vnc, ipp, smb, ftp]
///
/// for try await endpoint in BonjourDiscovery().browse(serviceTypes: types, timeout: 4) {
///     print("\(endpoint.label): \(endpoint.url)")
/// }
/// ```
///
public struct DiscoveredEndpoint: Sendable, CustomStringConvertible {
	/// URL scheme, e.g. `"http"`, `"ws"`, `"tcp"`.
	public let scheme: String
	/// Display label mirroring ``BonjourServiceEntry/label``.
	public let label: String
	/// Bonjour instance name as advertised by the device.
	public let name: String
	/// Resolved host address or hostname (interface scope suffix stripped).
	public let host: String
	/// Resolved TCP port.
	public let port: Int
	/// Base path from the mDNS TXT record, or ``BonjourServiceEntry/defaultPath``
	/// when the record is absent. Empty for NMEA / vendor endpoints.
	public let path: String

	/// Creates a discovered endpoint.
	public init(scheme: String, label: String, name: String, host: String, port: Int, path: String) {
		self.scheme = scheme
		self.label = label
		self.name = name
		self.host = host
		self.port = port
		self.path = path
	}

	/// Ready-to-use connection URL built from the resolved components.
	///
	/// Examples:
	/// - `"http://192.168.1.20:3000/signalk"` — Signal K HTTP server
	/// - `"ws://192.168.1.20:3001/signalk"`   — Signal K WebSocket server
	/// - `"tcp://192.168.1.5:10110"`           — Raw NMEA 0183 stream
	public var url: String { "\(scheme)://\(host):\(port)\(path)" }

	/// A human-readable description combining the label, name and URL.
	public var description: String { "[\(label)] \(name) — \(url)" }
}

// MARK: - Service type registry

/// A Bonjour/mDNS service type to browse, with the URL parameters to apply once
/// a matching instance is resolved.
public struct BonjourServiceEntry: Sendable {
	/// Bonjour/mDNS service type string, e.g. `"_signalk-http._tcp"`.
	public let bonjourType: String
	/// URL scheme used to build ``DiscoveredEndpoint/url``.
	public let scheme: String
	/// Base path appended to the URL when the TXT record carries none.
	/// Defaults to `""`. Use `"/signalk"` for Signal K servers.
	public let defaultPath: String
	/// Display label propagated to ``DiscoveredEndpoint/label``.
	public let label: String

	/// Creates a service type entry.
	///
	/// - Parameters:
	///   - bonjourType: mDNS PTR service type, e.g. `"_signalk-http._tcp"`.
	///   - scheme: URL scheme for the resolved endpoint, e.g. `"http"` or `"tcp"`.
	///   - defaultPath: Base path when the TXT record has none. Defaults to `""`.
	///   - label: Human-readable tag shown in listings.
	public init(bonjourType: String, scheme: String, defaultPath: String = "", label: String) {
		self.bonjourType = bonjourType
		self.scheme = scheme
		self.defaultPath = defaultPath
		self.label = label
	}
}

/// Default mDNS service types browsed by ``BonjourDiscovery``.
///
/// Covers common service categories — marine, file sharing, printing, multimedia,
/// remote access, web and IoT. Vendor-specific entries are best-effort and harmless
/// if a device doesn't advertise them — add confirmed types from `dns-sd -B` output.
public let bonjourDefaultServiceTypes: [BonjourServiceEntry] = [
	// Marine — standards
	.init(bonjourType: "_signalk-http._tcp", scheme: "http", defaultPath: "/signalk", label: "signalk-http"),
	.init(bonjourType: "_signalk-ws._tcp", scheme: "ws", defaultPath: "/signalk", label: "signalk-ws"),
	.init(bonjourType: "_nmea-0183._tcp", scheme: "tcp", label: "nmea-0183"),
	// Marine — vendor-specific
	.init(bonjourType: "_garmin-marine._tcp", scheme: "tcp", label: "garmin-marine"),
	.init(bonjourType: "_navico-mfd._tcp", scheme: "tcp", label: "navico-mfd"),
	.init(bonjourType: "_raymarine-net._tcp", scheme: "tcp", label: "raymarine-net"),
	.init(bonjourType: "_furuno-navnet._tcp", scheme: "tcp", label: "furuno-navnet"),

	// File sharing
	.init(bonjourType: "_smb._tcp", scheme: "smb", label: "smb"),
	.init(bonjourType: "_afpovertcp._tcp", scheme: "afp", label: "afp"),
	.init(bonjourType: "_sftp-ssh._tcp", scheme: "sftp", label: "sftp"),
	.init(bonjourType: "_ftp._tcp", scheme: "ftp", label: "ftp"),
	.init(bonjourType: "_nfs._tcp", scheme: "nfs", label: "nfs"),
	.init(bonjourType: "_webdav._tcp", scheme: "http", defaultPath: "/", label: "webdav"),

	// Printing
	.init(bonjourType: "_ipp._tcp", scheme: "ipp", label: "ipp"),
	.init(bonjourType: "_ipps._tcp", scheme: "ipps", label: "ipps"),
	.init(bonjourType: "_printer._tcp", scheme: "lpr", label: "printer"),
	.init(bonjourType: "_pdl-datastream._tcp", scheme: "tcp", label: "pdl-datastream"),

	// Multimedia
	.init(bonjourType: "_raop._tcp", scheme: "raop", label: "airplay-audio"),
	.init(bonjourType: "_airplay._tcp", scheme: "http", label: "airplay-video"),
	.init(bonjourType: "_googlecast._tcp", scheme: "http", label: "chromecast"),
	.init(bonjourType: "_daap._tcp", scheme: "daap", label: "itunes-daap"),

	// Remote access
	.init(bonjourType: "_ssh._tcp", scheme: "ssh", label: "ssh"),
	.init(bonjourType: "_rfb._tcp", scheme: "vnc", label: "vnc"),
	.init(bonjourType: "_rdp._tcp", scheme: "rdp", label: "rdp"),

	// Web & IoT
	.init(bonjourType: "_http._tcp", scheme: "http", label: "http"),
	.init(bonjourType: "_https._tcp", scheme: "https", label: "https"),
	.init(bonjourType: "_hap._tcp", scheme: "tcp", label: "homekit"),
	.init(bonjourType: "_mqtt._tcp", scheme: "tcp", label: "mqtt"),
]

// MARK: - BonjourDiscovery — Apple (Network.framework / NWBrowser)

#if canImport(Network)

	@preconcurrency internal import Network
	internal import Foundation

	/// Discovers services on the local network via mDNS Bonjour.
	///
	/// Backend per platform:
	/// - **macOS / iOS / watchOS / tvOS / visionOS**: `NWBrowser` from `Network.framework`.
	/// - **Windows**: native `DnsServiceBrowse` / `DnsServiceResolve` from `windns.h`
	///   (Windows 10 1709 and later, no third-party install).
	/// - **Linux**: Avahi via the `dns_sd` C compat API (`libavahi-compat-libdnssd-dev`).
	///
	public final class BonjourDiscovery: @unchecked Sendable {
		private let queue = DispatchQueue(label: "Stheno.BonjourDiscovery")

		/// Creates a Bonjour discovery controller.
		public init() {}

		/// Browses mDNS service types and yields discovered endpoints.
		///
		/// The stream finishes after `timeout` seconds. Discard it early to stop browsing.
		///
		/// - Parameters:
		///   - serviceTypes: Service types to browse. Defaults to ``bonjourDefaultServiceTypes``.
		///   - timeout: Scan duration in seconds. Default is 5 s.
		public func browse(
			serviceTypes: [BonjourServiceEntry] = bonjourDefaultServiceTypes,
			timeout: Double = 5
		) -> AsyncThrowingStream<DiscoveredEndpoint, any Error> {
			AsyncThrowingStream { continuation in
				let q = self.queue
				let browsers = serviceTypes.map { entry in
					Self.makeBrowser(entry: entry, queue: q, continuation: continuation)
				}
				continuation.onTermination = { @Sendable _ in for b in browsers { b.cancel() } }
				q.asyncAfter(deadline: .now() + timeout) {
					continuation.finish()
					for b in browsers { b.cancel() }
				}
				for b in browsers { b.start(queue: q) }
			}
		}

		private static func makeBrowser(
			entry: BonjourServiceEntry,
			queue: DispatchQueue,
			continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
		) -> NWBrowser {
			let descriptor = NWBrowser.Descriptor.bonjourWithTXTRecord(type: entry.bonjourType, domain: nil)
			let browser = NWBrowser(for: descriptor, using: .tcp)
			browser.browseResultsChangedHandler = { _, changes in
				for change in changes {
					guard case .added(let result) = change else { continue }
					resolveEndpoint(result: result, entry: entry, queue: queue, continuation: continuation)
				}
			}
			return browser
		}
	}

	/// Opens a transient `NWConnection` to resolve host/port for a Bonjour result,
	/// yields a ``DiscoveredEndpoint``, then cancels the connection immediately.
	private func resolveEndpoint(
		result: NWBrowser.Result,
		entry: BonjourServiceEntry,
		queue: DispatchQueue,
		continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
	) {
		guard case .service(let name, _, _, _) = result.endpoint else { return }

		let path: String = {
			if case .bonjour(let txt) = result.metadata,
				let p = txt["path"], !p.isEmpty
			{
				return p
			}
			return entry.defaultPath
		}()

		let connection = NWConnection(to: result.endpoint, using: .tcp)
		connection.stateUpdateHandler = { state in
			switch state {
			case .ready:
				if let cp = connection.currentPath,
					case .hostPort(let h, let port) = cp.remoteEndpoint
				{
					let raw: String
					switch h {
					case .name(let n, _): raw = n
					case .ipv4(let a): raw = "\(a)"
					case .ipv6(let a): raw = "\(a)"
					@unknown default: raw = "\(h)"
					}
					// Strip interface scope suffix (e.g. `192.168.1.16%en0`).
					let host = raw.split(separator: "%", maxSplits: 1).first.map(String.init) ?? raw
					continuation.yield(
						DiscoveredEndpoint(
							scheme: entry.scheme, label: entry.label, name: name,
							host: host, port: Int(port.rawValue), path: path))
				}
				connection.cancel()
			case .failed:
				connection.cancel()
			default:
				break
			}
		}
		connection.start(queue: queue)
	}

// MARK: - BonjourDiscovery — Windows (native DnsServiceBrowse from windns.h)

#elseif os(Windows)

	import WinSDK
	internal import Foundation

	// MARK: Context objects

	private final class WinBrowseCtx: @unchecked Sendable {
		let entry: BonjourServiceEntry
		let continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
		var cancel = DNS_SERVICE_CANCEL()
		init(
			entry: BonjourServiceEntry,
			continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
		) {
			self.entry = entry
			self.continuation = continuation
		}
	}

	private final class WinResolveCtx: @unchecked Sendable {
		let name: String
		let entry: BonjourServiceEntry
		let continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
		var cancel = DNS_SERVICE_CANCEL()
		init(
			name: String, entry: BonjourServiceEntry,
			continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
		) {
			self.name = name
			self.entry = entry
			self.continuation = continuation
		}
	}

	// MARK: C callbacks

	// PDNS_SERVICE_BROWSE_CALLBACK's third argument is typed PDNS_RECORDA in the SDK
	// (PDNS_RECORD == PDNS_RECORDA), even though DnsServiceBrowse with a UTF-16 query
	// name returns wide-string records.  Take the parameter as DNS_RECORDA to satisfy
	// the type system, then rebind to DNS_RECORDW for correct string decoding.
	private let winBrowseCallback:
		@convention(c) (
			DWORD, UnsafeMutableRawPointer?, UnsafeMutablePointer<DNS_RECORDA>?
		) -> Void = { status, context, dnsRecordA in
			guard status == ERROR_SUCCESS, let context, let dnsRecordA else { return }
			let browseCtx = Unmanaged<WinBrowseCtx>.fromOpaque(context).takeUnretainedValue()
			var cur: UnsafeMutablePointer<DNS_RECORDW>? = UnsafeMutableRawPointer(dnsRecordA)
				.assumingMemoryBound(to: DNS_RECORDW.self)
			while let rec = cur {
				if rec.pointee.wType == DNS_TYPE_PTR,
					let nameHost = rec.pointee.Data.PTR.pNameHost
				{
					let instanceName = String(decodingCString: nameHost, as: UTF16.self)
					startWinResolve(
						name: instanceName,
						entry: browseCtx.entry,
						continuation: browseCtx.continuation)
				}
				cur = rec.pointee.pNext
			}
			// DnsRecordListFree is a C function-like macro and cannot be called from Swift;
			// call the underlying function directly.
			DnsFree(dnsRecordA, DnsFreeRecordList)
		}

	private let winResolveCallback:
		@convention(c) (
			DWORD, UnsafeMutableRawPointer?, UnsafeMutablePointer<DNS_SERVICE_INSTANCE>?
		) -> Void = { status, context, instance in
			guard let context else { return }
			let ctx = Unmanaged<WinResolveCtx>.fromOpaque(context).takeRetainedValue()
			guard status == ERROR_SUCCESS, let instance else { return }
			defer { DnsServiceFreeInstance(instance) }

			let host: String = {
				guard let h = instance.pointee.pszHostName else { return "" }
				var s = String(decodingCString: h, as: UTF16.self)
				if s.hasSuffix(".") { s.removeLast() }
				return s
			}()
			let port = Int(instance.pointee.wPort)

			var path = ctx.entry.defaultPath
			let propCount = Int(instance.pointee.dwPropertyCount)
			if propCount > 0,
				let keys = instance.pointee.keys,
				let values = instance.pointee.values
			{
				for i in 0..<propCount {
					guard let kPtr = keys[i] else { continue }
					let k = String(decodingCString: kPtr, as: UTF16.self)
					if k == "path", let vPtr = values[i] {
						let v = String(decodingCString: vPtr, as: UTF16.self)
						if !v.isEmpty { path = v }
					}
				}
			}

			ctx.continuation.yield(
				DiscoveredEndpoint(
					scheme: ctx.entry.scheme, label: ctx.entry.label,
					name: ctx.name, host: host, port: port, path: path))
		}

	private func startWinResolve(
		name: String,
		entry: BonjourServiceEntry,
		continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
	) {
		let ctx = WinResolveCtx(name: name, entry: entry, continuation: continuation)
		let ctxPtr = Unmanaged.passRetained(ctx).toOpaque()
		name.withCString(encodedAs: UTF16.self) { (namePtr: UnsafePointer<UInt16>) in
			var req = DNS_SERVICE_RESOLVE_REQUEST()
			req.Version = ULONG(DNS_QUERY_REQUEST_VERSION1)
			req.InterfaceIndex = 0
			// DNS_SERVICE_RESOLVE_REQUEST.QueryName is PWSTR (mutable wide string),
			// unlike DNS_SERVICE_BROWSE_REQUEST.QueryName which is PCWSTR (const).
			// DnsServiceResolve does not write through the pointer; mutating cast is safe.
			req.QueryName = UnsafeMutablePointer(mutating: namePtr)
			req.pResolveCompletionCallback = winResolveCallback
			req.pQueryContext = ctxPtr
			let result = DnsServiceResolve(&req, &ctx.cancel)
			if result != DNS_REQUEST_PENDING {
				Unmanaged<WinResolveCtx>.fromOpaque(ctxPtr).release()
			}
		}
	}

	// MARK: BonjourDiscovery

	/// Discovers services on the local network via mDNS Bonjour.
	///
	/// On **Windows**, uses the native `DnsServiceBrowse` / `DnsServiceResolve` API
	/// from `windns.h` (Windows 10 1709 and later — no third-party install required).
	public final class BonjourDiscovery: @unchecked Sendable {
		/// Creates a Bonjour discovery controller.
		public init() {}

		/// Browses mDNS service types and yields discovered endpoints.
		///
		/// The stream finishes after `timeout` seconds. Discard it early to stop browsing.
		///
		/// - Parameters:
		///   - serviceTypes: Service types to browse. Defaults to ``bonjourDefaultServiceTypes``.
		///   - timeout: Scan duration in seconds. Default is 5 s.
		public func browse(
			serviceTypes: [BonjourServiceEntry] = bonjourDefaultServiceTypes,
			timeout: Double = 5
		) -> AsyncThrowingStream<DiscoveredEndpoint, any Error> {
			AsyncThrowingStream { continuation in
				var browseContexts: [Unmanaged<WinBrowseCtx>] = []
				for entry in serviceTypes {
					let queryName =
						entry.bonjourType.hasSuffix(".local")
						? entry.bonjourType
						: "\(entry.bonjourType).local"
					let ctx = WinBrowseCtx(entry: entry, continuation: continuation)
					let unmanaged = Unmanaged.passRetained(ctx)
					queryName.withCString(encodedAs: UTF16.self) { (namePtr: UnsafePointer<UInt16>) in
						var req = DNS_SERVICE_BROWSE_REQUEST()
						req.Version = ULONG(DNS_QUERY_REQUEST_VERSION1)
						req.InterfaceIndex = 0
						req.QueryName = namePtr
						req.pBrowseCallback = winBrowseCallback
						req.pQueryContext = unmanaged.toOpaque()
						let result = DnsServiceBrowse(&req, &ctx.cancel)
						if result == DNS_REQUEST_PENDING {
							browseContexts.append(unmanaged)
						} else {
							unmanaged.release()
						}
					}
				}
				let toCancel = browseContexts
				continuation.onTermination = { @Sendable _ in
					for u in toCancel {
						let c = u.takeUnretainedValue()
						DnsServiceBrowseCancel(&c.cancel)
					}
				}
				DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
					for u in toCancel {
						let c = u.takeUnretainedValue()
						DnsServiceBrowseCancel(&c.cancel)
					}
					continuation.finish()
					for u in toCancel { u.release() }
				}
			}
		}
	}

// MARK: - BonjourDiscovery — Linux (dns_sd C API via Avahi compat layer)

#elseif os(Linux)

	import Cdns_sd
	internal import Foundation
	#if canImport(Glibc)
		import Glibc
	#endif

	// swift-corelibs-libdispatch on Linux does not yet annotate DispatchSourceRead
	// as Sendable, even though DispatchSource objects are inherently thread-safe.
	// This thin wrapper lets us capture a read source in @Sendable closures without
	// silencing all Sendable checking across the whole Dispatch import.
	private final class SendableReadSource: @unchecked Sendable {
		private let inner: any DispatchSourceRead
		init(_ source: any DispatchSourceRead) { inner = source }
		func cancel() { inner.cancel() }
	}

	// MARK: Runtime loader for libdns_sd.so

	private struct AvahiAPI {
		let createConnection: PFN_DNSServiceCreateConnection
		let browse: PFN_DNSServiceBrowse
		let resolve: PFN_DNSServiceResolve
		let processResult: PFN_DNSServiceProcessResult
		let refDeallocate: PFN_DNSServiceRefDeallocate
		let refSockFD: PFN_DNSServiceRefSockFD
		let txtRecordGetValuePtr: PFN_TXTRecordGetValuePtr
	}

	private enum AvahiLoader {
		static let api: AvahiAPI? = load()
		private static func load() -> AvahiAPI? {
			let candidates = ["libdns_sd.so.1", "libdns_sd.so"]
			var handle: UnsafeMutableRawPointer?
			for name in candidates {
				handle = dlopen(name, RTLD_LAZY)
				if handle != nil { break }
			}
			guard let h = handle else { return nil }
			func sym<T>(_ name: String, as _: T.Type) -> T? {
				guard let p = dlsym(h, name) else { return nil }
				return unsafeBitCast(p, to: T.self)
			}
			guard
				let f0: PFN_DNSServiceCreateConnection = sym(
					"DNSServiceCreateConnection", as: PFN_DNSServiceCreateConnection.self),
				let f1: PFN_DNSServiceBrowse = sym("DNSServiceBrowse", as: PFN_DNSServiceBrowse.self),
				let f2: PFN_DNSServiceResolve = sym("DNSServiceResolve", as: PFN_DNSServiceResolve.self),
				let f3: PFN_DNSServiceProcessResult = sym(
					"DNSServiceProcessResult", as: PFN_DNSServiceProcessResult.self),
				let f4: PFN_DNSServiceRefDeallocate = sym(
					"DNSServiceRefDeallocate", as: PFN_DNSServiceRefDeallocate.self),
				let f5: PFN_DNSServiceRefSockFD = sym("DNSServiceRefSockFD", as: PFN_DNSServiceRefSockFD.self),
				let f6: PFN_TXTRecordGetValuePtr = sym("TXTRecordGetValuePtr", as: PFN_TXTRecordGetValuePtr.self)
			else { return nil }
			return AvahiAPI(
				createConnection: f0, browse: f1, resolve: f2,
				processResult: f3, refDeallocate: f4, refSockFD: f5,
				txtRecordGetValuePtr: f6)
		}
	}

	// MARK: Context objects

	private final class BrowseCtx: @unchecked Sendable {
		let entry: BonjourServiceEntry
		let mainRef: DNSServiceRef
		let continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
		init(
			entry: BonjourServiceEntry, mainRef: DNSServiceRef,
			continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
		) {
			self.entry = entry
			self.mainRef = mainRef
			self.continuation = continuation
		}
	}

	private final class ResolveCtx: @unchecked Sendable {
		let name: String
		let entry: BonjourServiceEntry
		let continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
		init(
			name: String, entry: BonjourServiceEntry,
			continuation: AsyncThrowingStream<DiscoveredEndpoint, any Error>.Continuation
		) {
			self.name = name
			self.entry = entry
			self.continuation = continuation
		}
	}

	// MARK: C callbacks

	private let dnsBrowseReply: DNSServiceBrowseReply = {
		_, flags, interfaceIndex, errorCode, serviceName, regtype, replyDomain, context in
		guard errorCode == kDNSServiceErr_NoError,
			flags & DNSServiceFlags(kDNSServiceFlagsAdd) != 0,
			let context, let serviceName, let regtype, let replyDomain,
			let api = AvahiLoader.api
		else { return }
		let browseCtx = Unmanaged<BrowseCtx>.fromOpaque(context).takeUnretainedValue()
		let name = String(cString: serviceName)
		let resolveCtx = ResolveCtx(
			name: name, entry: browseCtx.entry,
			continuation: browseCtx.continuation)
		let resolvePtr = Unmanaged.passRetained(resolveCtx).toOpaque()
		var subRef: DNSServiceRef? = browseCtx.mainRef
		let err = api.resolve(
			&subRef, DNSServiceFlags(kDNSServiceFlagsShareConnection),
			interfaceIndex, serviceName, regtype, replyDomain,
			dnsResolveReply, resolvePtr)
		if err != kDNSServiceErr_NoError {
			Unmanaged<ResolveCtx>.fromOpaque(resolvePtr).release()
		}
	}

	private let dnsResolveReply: DNSServiceResolveReply = {
		sdRef, _, _, errorCode, _, hosttarget, port, txtLen, txtRecord, context in
		guard let context else { return }
		let ctx = Unmanaged<ResolveCtx>.fromOpaque(context).takeRetainedValue()
		guard errorCode == kDNSServiceErr_NoError, let hosttarget else {
			if let ref = sdRef, let api = AvahiLoader.api { api.refDeallocate(ref) }
			return
		}
		let host = String(cString: hosttarget)
		let portNum = Int(UInt16(bigEndian: port))
		var path = ctx.entry.defaultPath
		if let txtRecord, txtLen > 0, let api = AvahiLoader.api {
			var valueLen: UInt8 = 0
			if let ptr = api.txtRecordGetValuePtr(txtLen, txtRecord, "path", &valueLen),
				valueLen > 0
			{
				let bytes = UnsafeBufferPointer(
					start: ptr.assumingMemoryBound(to: UInt8.self), count: Int(valueLen))
				path = String(bytes: Array(bytes), encoding: .utf8) ?? path
			}
		}
		ctx.continuation.yield(
			DiscoveredEndpoint(
				scheme: ctx.entry.scheme, label: ctx.entry.label,
				name: ctx.name, host: host, port: portNum, path: path))
		if let ref = sdRef, let api = AvahiLoader.api { api.refDeallocate(ref) }
	}

	// MARK: BonjourDiscovery

	/// Discovers services on the local network via mDNS Bonjour.
	///
	/// Uses Avahi via the `dns_sd` C compatibility API on Linux
	/// (requires `libavahi-compat-libdnssd-dev`).
	public final class BonjourDiscovery: @unchecked Sendable {
		private let queue = DispatchQueue(label: "Stheno.BonjourDiscovery.dns_sd")
		private var browseContexts: [Unmanaged<BrowseCtx>] = []

		/// Creates a Bonjour discovery controller.
		public init() {}

		/// Browses mDNS service types and yields discovered endpoints.
		///
		/// The stream finishes after `timeout` seconds. Discard it early to stop browsing.
		///
		/// - Parameters:
		///   - serviceTypes: Service types to browse. Defaults to ``bonjourDefaultServiceTypes``.
		///   - timeout: Scan duration in seconds. Default is 5 s.
		public func browse(
			serviceTypes: [BonjourServiceEntry] = bonjourDefaultServiceTypes,
			timeout: Double = 5
		) -> AsyncThrowingStream<DiscoveredEndpoint, any Error> {
			AsyncThrowingStream { [self] continuation in
				guard let api = AvahiLoader.api else {
					continuation.finish(
						throwing: BonjourDiscoveryError(
							"""
							Bonjour discovery requires the Avahi mDNS library.
							Install it on Debian/Ubuntu with:
							    sudo apt install libavahi-compat-libdnssd1
							On Fedora/RHEL:
							    sudo dnf install avahi-compat-libdns_sd
							"""))
					return
				}
				var mainRef: DNSServiceRef?
				guard api.createConnection(&mainRef) == kDNSServiceErr_NoError,
					let main = mainRef
				else {
					continuation.finish(
						throwing: BonjourDiscoveryError(
							"DNSServiceCreateConnection failed — is the avahi-daemon running?"))
					return
				}
				for entry in serviceTypes {
					let ctx = BrowseCtx(entry: entry, mainRef: main, continuation: continuation)
					let unmanaged = Unmanaged.passRetained(ctx)
					browseContexts.append(unmanaged)
					var subRef: DNSServiceRef? = main
					let err = api.browse(
						&subRef, DNSServiceFlags(kDNSServiceFlagsShareConnection),
						0, entry.bonjourType, nil, dnsBrowseReply, unmanaged.toOpaque())
					if err != kDNSServiceErr_NoError {
						_ = unmanaged.takeRetainedValue()
						browseContexts.removeLast()
					}
				}
				let ctxsToRelease = browseContexts
				let fd = api.refSockFD(main)
				let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)
				source.setEventHandler {
					if api.processResult(main) != kDNSServiceErr_NoError { source.cancel() }
				}
				source.setCancelHandler {
					api.refDeallocate(main)
					for ctx in ctxsToRelease { ctx.release() }
					continuation.finish()
				}
				source.activate()
				let sendableSource = SendableReadSource(source)
				queue.asyncAfter(deadline: .now() + timeout) { sendableSource.cancel() }
				continuation.onTermination = { @Sendable _ in sendableSource.cancel() }
			}
		}
	}

// MARK: - BonjourDiscovery — unsupported platforms (Android, WASM, …)
// Platforms that reach this branch have no Bonjour/mDNS backend available.
// browse() throws immediately so callers get a clear diagnostic rather than
// a link error or a silent no-op.

#else

	/// Discovers services on the local network via mDNS Bonjour.
	///
	/// > Note: This platform has no supported mDNS backend. ``browse(serviceTypes:timeout:)``
	/// > always throws ``BonjourDiscoveryError``.
	public final class BonjourDiscovery: @unchecked Sendable {
		/// Creates a Bonjour discovery controller.
		public init() {}

		/// Browses mDNS service types and yields discovered endpoints.
		///
		/// The stream finishes after `timeout` seconds. Discard it early to stop browsing.
		///
		/// - Parameters:
		///   - serviceTypes: Service types to browse. Defaults to ``bonjourDefaultServiceTypes``.
		///   - timeout: Scan duration in seconds. Default is 5 s.
		public func browse(
			serviceTypes: [BonjourServiceEntry] = bonjourDefaultServiceTypes,
			timeout: Double = 5
		) -> AsyncThrowingStream<DiscoveredEndpoint, any Error> {
			AsyncThrowingStream { continuation in
				continuation.finish(
					throwing: BonjourDiscoveryError(
						"Bonjour discovery is not supported on this platform."))
			}
		}
	}

#endif  // canImport(Network) / os(Windows) / os(Linux) / other

// mDNS Bonjour discovery for the C ABI — the marine servers advertising
// themselves on the local network, so a host can offer them instead of asking
// the user to type an address.

internal import Dispatch
internal import Foundation
internal import Stheno
internal import Synchronization

/// One endpoint found on the network, as serialised to the host.
private struct EndpointPayload: Encodable {
	/// The Bonjour label of the service type, e.g. `signalk-ws`, `nmea-0183`.
	let label: String
	/// The instance name the server advertises.
	let name: String
	let host: String
	let port: Int
	/// Ready to open, e.g. `ws://192.168.1.10:3000/signalk`.
	let url: String
}

/// What `stheno_bridge_discover` returns.
private struct DiscoveryPayload: Encodable {
	let ok: Bool
	/// Why the scan could not run — a missing mDNS back-end, typically. Worth
	/// showing: on Windows it means Apple's Bonjour service is absent, on Linux
	/// Avahi, and on Android the platform has no back-end here at all and the
	/// host must browse with its own API.
	var error: String?
	var endpoints: [EndpointPayload] = []
}

/// Browses the local network for marine servers over mDNS Bonjour.
///
/// Blocks for the whole scan — call from a background thread.
///
/// - Parameters:
///   - types: Comma-separated Bonjour service types to browse, e.g.
///     `_signalk-ws._tcp,_nmea-0183._tcp`. NULL or empty browses Stheno's
///     marine defaults (Signal K over HTTP and WebSocket, NMEA 0183, and the
///     Garmin / Navico / Raymarine / Furuno vendor types).
///   - timeoutSeconds: Scan duration; values ≤ 0 default to 5 s.
/// - Returns: JSON `{"ok","error","endpoints":[{label,name,host,port,url}]}`
///   to release with `stheno_bridge_string_free`.
@_cdecl("stheno_bridge_discover")
public func stheno_bridge_discover(
	_ types: UnsafePointer<CChar>?, _ timeoutSeconds: Double
) -> UnsafeMutablePointer<CChar>? {
	let requested = types.map { String(cString: $0) } ?? ""
	let timeout = timeoutSeconds > 0 ? timeoutSeconds : 5
	let types = serviceTypes(from: requested)

	let payload = awaitBlocking { () -> DiscoveryPayload in
		var found: [EndpointPayload] = []
		do {
			for try await endpoint in BonjourDiscovery().browse(
				serviceTypes: types, timeout: timeout)
			{
				found.append(
					EndpointPayload(
						label: endpoint.label, name: endpoint.name,
						host: endpoint.host, port: endpoint.port, url: endpoint.url))
			}
			return DiscoveryPayload(ok: true, endpoints: found)
		} catch {
			// Whatever arrived before the failure is still worth showing.
			return DiscoveryPayload(ok: false, error: "\(error)", endpoints: found)
		}
	}
	guard let data = try? JSONEncoder().encode(payload) else {
		return cString(#"{"ok":false,"error":"encoding failed","endpoints":[]}"#)
	}
	return cString(String(decoding: data, as: UTF8.self))
}

/// Resolves the requested service types, keeping the marine defaults' scheme
/// and path mapping for any type Stheno already knows — that mapping is what
/// makes an endpoint's `url` directly openable.
func serviceTypes(from list: String) -> [BonjourServiceEntry] {
	let names = list.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
		.filter { $0.isEmpty == false }
	guard names.isEmpty == false else { return bonjourDefaultServiceTypes }
	return names.map { name in
		bonjourDefaultServiceTypes.first { $0.bonjourType == name }
			?? BonjourServiceEntry(bonjourType: name, scheme: "tcp", label: name)
	}
}

/// Carries a result across the semaphore. `NSLock` rather than `Mutex`: this
/// bridge's deployment target predates the Synchronization primitives.
private final class ResultBox<T>: @unchecked Sendable {
	// @unchecked: `value` is only ever touched under `lock`.
	private let lock = NSLock()
	private var value: T?

	func store(_ newValue: T) { lock.withLock { value = newValue } }
	func take() -> T? { lock.withLock { value } }
}

/// Runs an async operation to completion on the calling C thread — safe
/// because P/Invoke callers are .NET worker threads, never part of Swift
/// concurrency's cooperative pool.
private func awaitBlocking<T: Sendable>(_ operation: @escaping @Sendable () async -> T) -> T {
	let semaphore = DispatchSemaphore(value: 0)
	let box = ResultBox<T>()
	Task {
		box.store(await operation())
		semaphore.signal()
	}
	semaphore.wait()
	return box.take()!
}

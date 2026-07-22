import Foundation
import Testing

@testable import SthenoBridge

/// The Bonjour surface of the C ABI. The scan itself depends on what happens
/// to be on the network, so what is pinned here is the contract around it: how
/// the requested service types are resolved, and that the payload is
/// well-formed whether or not the platform has an mDNS back-end.
@Suite("Bridge discovery")
struct DiscoveryTests {

	@Test("An empty list browses the marine defaults")
	func emptyListUsesDefaults() {
		#expect(serviceTypes(from: "").count > 1)
		#expect(serviceTypes(from: "  ").isEmpty == false)
		// Signal K over WebSocket is the case that matters most: its scheme and
		// path are what make an endpoint's URL directly openable.
		let signalK = serviceTypes(from: "").first { $0.bonjourType == "_signalk-ws._tcp" }
		#expect(signalK?.scheme == "ws")
		#expect(signalK?.defaultPath == "/signalk")
	}

	@Test("A known type keeps the scheme and path that make its URL openable")
	func knownTypeKeepsItsMapping() {
		let types = serviceTypes(from: "_signalk-http._tcp")
		#expect(types.count == 1)
		#expect(types.first?.scheme == "http")
		#expect(types.first?.defaultPath == "/signalk")
	}

	@Test("An unknown type is still browsed, as a plain TCP service")
	func unknownTypeFallsBackToTcp() {
		let types = serviceTypes(from: "_my-gateway._tcp")
		#expect(types.count == 1)
		#expect(types.first?.bonjourType == "_my-gateway._tcp")
		#expect(types.first?.scheme == "tcp")
	}

	@Test("Several types are split, trimmed and kept in order")
	func listIsSplitAndTrimmed() {
		let types = serviceTypes(from: " _signalk-ws._tcp , _nmea-0183._tcp ")
		#expect(types.map(\.bonjourType) == ["_signalk-ws._tcp", "_nmea-0183._tcp"])
	}

	@Test("A blank entry between separators is dropped, not browsed")
	func blankEntriesAreDropped() {
		#expect(serviceTypes(from: "_nmea-0183._tcp,,").count == 1)
	}

	@Test("A scan returns a well-formed payload, back-end or not")
	func scanPayloadIsWellFormed() throws {
		// A brief scan: the point is the shape of the answer. On a platform
		// with no mDNS back-end this reports ok:false with a reason, which is
		// exactly what a host needs to tell the user.
		let pointer = try #require(
			"_nmea-0183._tcp".withCString { stheno_bridge_discover($0, 0.5) })
		let json = String(cString: pointer)
		stheno_bridge_string_free(pointer)

		let payload = try #require(json.data(using: .utf8))
		let decoded = try JSONSerialization.jsonObject(with: payload) as? [String: Any]
		let object = try #require(decoded)
		#expect(object["ok"] is Bool)
		#expect(object["endpoints"] is [Any])
	}
}

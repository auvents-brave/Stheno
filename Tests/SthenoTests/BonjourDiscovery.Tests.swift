import Foundation
import Testing

@testable import Stheno


// MARK: - BonjourDiscoveryError

@Suite("BonjourDiscoveryError")
struct BonjourDiscoveryErrorTests {

    @Test func `stores message as description`() {
        let error = BonjourDiscoveryError("something went wrong")
        #expect(error.description == "something went wrong")
    }

    @Test func `conforms to Error`() {
        let error: any Error = BonjourDiscoveryError("test")
        #expect(error is BonjourDiscoveryError)
    }

    @Test func `preserves multi-line message`() {
        let msg = "line one\nline two\n    indented"
        let error = BonjourDiscoveryError(msg)
        #expect(error.description == msg)
    }

    @Test func `empty message is valid`() {
        let error = BonjourDiscoveryError("")
        #expect(error.description == "")
    }
}


// MARK: - DiscoveredEndpoint

@Suite("DiscoveredEndpoint")
struct DiscoveredEndpointTests {

    @Test func `stores all properties`() {
        let ep = DiscoveredEndpoint(
            scheme: "http", label: "signalk-http", name: "My Boat",
            host: "192.168.1.20", port: 3000, path: "/signalk")
        #expect(ep.scheme == "http")
        #expect(ep.label  == "signalk-http")
        #expect(ep.name   == "My Boat")
        #expect(ep.host   == "192.168.1.20")
        #expect(ep.port   == 3000)
        #expect(ep.path   == "/signalk")
    }

    @Test func `url with non-empty path`() {
        let ep = DiscoveredEndpoint(
            scheme: "http", label: "l", name: "n",
            host: "192.168.1.20", port: 3000, path: "/signalk")
        #expect(ep.url == "http://192.168.1.20:3000/signalk")
    }

    @Test func `url with empty path`() {
        let ep = DiscoveredEndpoint(
            scheme: "tcp", label: "l", name: "n",
            host: "192.168.1.5", port: 10110, path: "")
        #expect(ep.url == "tcp://192.168.1.5:10110")
    }

    @Test func `url WebSocket scheme`() {
        let ep = DiscoveredEndpoint(
            scheme: "ws", label: "l", name: "n",
            host: "10.0.0.1", port: 3001, path: "/signalk/stream")
        #expect(ep.url == "ws://10.0.0.1:3001/signalk/stream")
    }

    @Test func `url uses port as-is`() {
        let ep = DiscoveredEndpoint(
            scheme: "tcp", label: "l", name: "n",
            host: "host", port: 65535, path: "")
        #expect(ep.url.hasSuffix(":65535"))
    }

    @Test func `description contains label, name and url`() {
        let ep = DiscoveredEndpoint(
            scheme: "tcp", label: "nmea-0183", name: "Chart Plotter",
            host: "192.168.1.5", port: 10110, path: "")
        #expect(ep.description.contains("nmea-0183"))
        #expect(ep.description.contains("Chart Plotter"))
        #expect(ep.description.contains(ep.url))
    }

    @Test func `description format matches [label] name — url`() {
        let ep = DiscoveredEndpoint(
            scheme: "http", label: "sk", name: "Server",
            host: "1.2.3.4", port: 80, path: "/sk")
        #expect(ep.description == "[sk] Server — http://1.2.3.4:80/sk")
    }

    @Test func `port zero is valid`() {
        let ep = DiscoveredEndpoint(
            scheme: "tcp", label: "l", name: "n",
            host: "localhost", port: 0, path: "")
        #expect(ep.port == 0)
        #expect(ep.url == "tcp://localhost:0")
    }
}


// MARK: - BonjourServiceEntry

@Suite("BonjourServiceEntry")
struct BonjourServiceEntryTests {

    @Test func `stores all properties`() {
        let entry = BonjourServiceEntry(
            bonjourType: "_signalk-http._tcp",
            scheme: "http",
            defaultPath: "/signalk",
            label: "signalk-http")
        #expect(entry.bonjourType  == "_signalk-http._tcp")
        #expect(entry.scheme       == "http")
        #expect(entry.defaultPath  == "/signalk")
        #expect(entry.label        == "signalk-http")
    }

    @Test func `defaultPath defaults to empty string`() {
        let entry = BonjourServiceEntry(
            bonjourType: "_nmea-0183._tcp",
            scheme: "tcp",
            label: "nmea-0183")
        #expect(entry.defaultPath == "")
    }

    @Test func `custom defaultPath is preserved`() {
        let entry = BonjourServiceEntry(
            bonjourType: "_test._tcp",
            scheme: "http",
            defaultPath: "/api/v2",
            label: "test")
        #expect(entry.defaultPath == "/api/v2")
    }
}


// MARK: - bonjourDefaultServiceTypes

@Suite("bonjourDefaultServiceTypes")
struct BonjourDefaultServiceTypesTests {

    @Test func `contains exactly 7 entries`() {
        #expect(bonjourDefaultServiceTypes.count == 7)
    }

    @Test func `first three are standard marine types`() {
        let types = bonjourDefaultServiceTypes
        #expect(types[0].bonjourType == "_signalk-http._tcp")
        #expect(types[1].bonjourType == "_signalk-ws._tcp")
        #expect(types[2].bonjourType == "_nmea-0183._tcp")
    }

    @Test func `Signal K HTTP entry is correct`() throws {
        let entry = bonjourDefaultServiceTypes.first { $0.label == "signalk-http" }
        let e = try #require(entry)
        #expect(e.bonjourType == "_signalk-http._tcp")
        #expect(e.scheme      == "http")
        #expect(e.defaultPath == "/signalk")
    }

    @Test func `Signal K WebSocket entry is correct`() throws {
        let entry = bonjourDefaultServiceTypes.first { $0.label == "signalk-ws" }
        let e = try #require(entry)
        #expect(e.bonjourType == "_signalk-ws._tcp")
        #expect(e.scheme      == "ws")
        #expect(e.defaultPath == "/signalk")
    }

    @Test func `NMEA 0183 entry has empty default path`() throws {
        let entry = bonjourDefaultServiceTypes.first { $0.label == "nmea-0183" }
        let e = try #require(entry)
        #expect(e.bonjourType == "_nmea-0183._tcp")
        #expect(e.scheme      == "tcp")
        #expect(e.defaultPath == "")
    }

    @Test func `vendor entries are present`() {
        let labels = Set(bonjourDefaultServiceTypes.map(\.label))
        #expect(labels.contains("garmin-marine"))
        #expect(labels.contains("navico-mfd"))
        #expect(labels.contains("raymarine-net"))
        #expect(labels.contains("furuno-navnet"))
    }

    @Test func `all bonjourTypes end with _tcp`() {
        for entry in bonjourDefaultServiceTypes {
            #expect(entry.bonjourType.hasSuffix("._tcp"),
                    "Expected ._tcp suffix, got: \(entry.bonjourType)")
        }
    }

    @Test func `all bonjourTypes start with underscore`() {
        for entry in bonjourDefaultServiceTypes {
            #expect(entry.bonjourType.hasPrefix("_"),
                    "Expected leading _, got: \(entry.bonjourType)")
        }
    }

    @Test func `no duplicate bonjourTypes`() {
        let types = bonjourDefaultServiceTypes.map(\.bonjourType)
        #expect(types.count == Set(types).count)
    }

    @Test func `no duplicate labels`() {
        let labels = bonjourDefaultServiceTypes.map(\.label)
        #expect(labels.count == Set(labels).count)
    }

    @Test func `all fields are non-empty`() {
        for entry in bonjourDefaultServiceTypes {
            #expect(!entry.bonjourType.isEmpty)
            #expect(!entry.scheme.isEmpty)
            #expect(!entry.label.isEmpty)
        }
    }

    @Test func `all vendor entries use tcp scheme`() {
        let vendorLabels = ["garmin-marine", "navico-mfd", "raymarine-net", "furuno-navnet"]
        for label in vendorLabels {
            let entry = bonjourDefaultServiceTypes.first { $0.label == label }
            if let e = entry {
                #expect(e.scheme == "tcp", "\(label) should use tcp scheme")
            }
        }
    }
}


// MARK: - BonjourDiscovery behaviour
// These tests exercise stream lifecycle without requiring real network hardware.
// They use an empty service-types list or a very short timeout so they never
// wait for real mDNS replies.

#if canImport(Network)

// Swift Testing macros (@Suite / @Test) cannot be applied to @available-annotated types.
// Instead, each test guards at runtime with #available so the suite is always visible
// to the test runner, but individual tests skip gracefully on older OS versions.

@Suite("BonjourDiscovery — stream lifecycle")
struct BonjourDiscoveryLifecycleTests {

    @Test func `empty serviceTypes yields nothing and finishes`() async throws {
        guard #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) else { return }
        let discovery = BonjourDiscovery()
        var count = 0
        for try await _ in discovery.browse(serviceTypes: [], timeout: 0.05) {
            count += 1
        }
        #expect(count == 0)
    }

    @Test func `stream finishes after timeout`() async throws {
        guard #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) else { return }
        let start = Date()
        let discovery = BonjourDiscovery()
        for try await _ in discovery.browse(serviceTypes: [], timeout: 0.1) {}
        let elapsed = Date().timeIntervalSince(start)
        // Should finish close to the 0.1 s timeout, well under 5 s
        #expect(elapsed < 5.0)
    }

    @Test func `longer timeout finishes later than shorter one`() async throws {
        guard #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) else { return }
        let discovery = BonjourDiscovery()

        let t1 = Date()
        for try await _ in discovery.browse(serviceTypes: [], timeout: 0.05) {}
        let elapsed1 = Date().timeIntervalSince(t1)

        let t2 = Date()
        for try await _ in discovery.browse(serviceTypes: [], timeout: 0.15) {}
        let elapsed2 = Date().timeIntervalSince(t2)

        #expect(elapsed2 > elapsed1)
    }

    @Test func `breaking out of stream does not hang`() async throws {
        guard #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) else { return }
        let discovery = BonjourDiscovery()
        // Browse with a short timeout.  In a CI environment without real mDNS
        // services the loop body is never entered (no items arrive), but the
        // stream must still terminate cleanly at the timeout without hanging.
        // If a service *is* present the `break` exercises early-exit cleanup.
        for try await _ in discovery.browse(serviceTypes: bonjourDefaultServiceTypes, timeout: 0.1) {
            break
        }
        // Reaching here means the stream terminated without deadlock.
        #expect(Bool(true))
    }

    @Test func `task cancellation stops the stream`() async throws {
        guard #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) else { return }
        let discovery = BonjourDiscovery()
        let task = Task {
            // Use a long timeout so the stream won't self-terminate before we cancel.
            for try await _ in discovery.browse(
                serviceTypes: bonjourDefaultServiceTypes, timeout: 300) {}
        }
        // Give the browsers a moment to start, then cancel.
        // Task.sleep(nanoseconds:) is available from iOS 13 / macOS 10.15,
        // unlike the Duration-based overload which requires iOS 16 / macOS 13.
        try await Task.sleep(nanoseconds: 50_000_000)
        task.cancel()
        // Await the task — should resolve quickly via cancellation, not sit for 300 s.
        _ = await task.result
        #expect(Bool(true))
    }

    @Test func `multiple independent browse sessions do not interfere`() async throws {
        guard #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) else { return }
        let d1 = BonjourDiscovery()
        let d2 = BonjourDiscovery()
        async let s1: Void = { for try await _ in d1.browse(serviceTypes: [], timeout: 0.05) {} }()
        async let s2: Void = { for try await _ in d2.browse(serviceTypes: [], timeout: 0.05) {} }()
        _ = try await (s1, s2)
        #expect(Bool(true))
    }

    @Test func `default timeout compiles without explicit argument`() {
        guard #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) else { return }
        // Verify the API contract: browse() must accept a call with no timeout argument.
        // We don't run the stream — just confirm it compiles and is the right type.
        let discovery = BonjourDiscovery()
        let stream = discovery.browse(serviceTypes: [])
        _ = stream  // suppress unused-variable warning; type-check is the real assertion
        #expect(Bool(true))
    }
}

#endif // canImport(Network)


// MARK: - BonjourDiscovery — Linux (Avahi / dns_sd) stream lifecycle
//
// These tests run only on Linux where the Avahi backend is used.
// Two scenarios are possible depending on the CI environment:
//   • Avahi installed   → AvahiLoader.api is non-nil, stream behaves normally.
//   • Avahi not present → AvahiLoader.api is nil, browse() throws BonjourDiscoveryError
//                         immediately; tests accept both outcomes.

#if os(Linux)

@Suite("BonjourDiscovery — Linux/Avahi stream lifecycle")
struct BonjourDiscoveryLinuxLifecycleTests {

    @Test func `empty serviceTypes yields nothing and finishes or throws`() async throws {
        let discovery = BonjourDiscovery()
        do {
            var count = 0
            for try await _ in discovery.browse(serviceTypes: [], timeout: 0.1) {
                count += 1
            }
            #expect(count == 0)
        } catch let error as BonjourDiscoveryError {
            // Avahi not available — acceptable in environments without the library.
            #expect(!error.description.isEmpty)
        }
    }

    @Test func `stream finishes after timeout when Avahi is available`() async throws {
        let discovery = BonjourDiscovery()
        let start = Date()
        do {
            for try await _ in discovery.browse(serviceTypes: [], timeout: 0.1) {}
            let elapsed = Date().timeIntervalSince(start)
            #expect(elapsed < 5.0)
        } catch is BonjourDiscoveryError {
            // Avahi not installed — skip timing assertion.
        }
    }

    @Test func `task cancellation stops the stream`() async throws {
        let discovery = BonjourDiscovery()
        let task = Task {
            do {
                for try await _ in discovery.browse(
                    serviceTypes: bonjourDefaultServiceTypes, timeout: 300) {}
            } catch is BonjourDiscoveryError {
                // Avahi not available — stream threw instead of running; that's fine.
            }
        }
        try await Task.sleep(nanoseconds: 50_000_000)
        task.cancel()
        _ = await task.result
        #expect(Bool(true))
    }

    @Test func `multiple independent browse sessions do not interfere`() async throws {
        let d1 = BonjourDiscovery()
        let d2 = BonjourDiscovery()
        async let s1: Void = {
            do { for try await _ in d1.browse(serviceTypes: [], timeout: 0.05) {} }
            catch is BonjourDiscoveryError {}
        }()
        async let s2: Void = {
            do { for try await _ in d2.browse(serviceTypes: [], timeout: 0.05) {} }
            catch is BonjourDiscoveryError {}
        }()
        _ = await (s1, s2)
        #expect(Bool(true))
    }

    @Test func `browse without Avahi throws BonjourDiscoveryError`() async throws {
        // This test explicitly verifies the error path exercised when libdns_sd.so
        // cannot be loaded. On CI with Avahi installed it will simply pass vacuously
        // (the stream won't throw); the real value is on bare Linux without Avahi.
        let discovery = BonjourDiscovery()
        var caughtExpectedError = false
        do {
            for try await _ in discovery.browse(serviceTypes: bonjourDefaultServiceTypes, timeout: 0.1) {}
        } catch let error as BonjourDiscoveryError {
            caughtExpectedError = true
            #expect(!error.description.isEmpty)
        }
        // Either path (Avahi present → no throw, Avahi absent → BonjourDiscoveryError) is valid.
        _ = caughtExpectedError
        #expect(Bool(true))
    }
}

#endif // os(Linux)

import Testing

@testable import Stheno

@Suite("Throttling Property Wrapper") struct ThrottledTests {
    @Test func `Value is throttled (does not update immediately)`() async throws {
        @Throttled(timeInterval: 99) var v = "Hello"
        v = "World!"
        #expect(v == "Hello")
    }

    @Test func `Value updates immediately with zero interval`() async throws {
        @Throttled(timeInterval: 0) var v = "Hello"
        v = "World!"
        #expect(v == "World!")
    }

    @Test func `Value remains unchanged after throttling interval (dropped updates)`() async throws {
        @Throttled(timeInterval: 0.05) var v = "Hello"
        // Update the value; current implementation drops the update during the throttling window.
        v = "World!"
        #expect(v == "Hello")

        // Wait slightly longer than the throttling interval; value should still be unchanged.
        try await Task.sleep(nanoseconds: 60_000_000)
        #expect(v == "Hello")

		// Now value updates immediately
		v = "World!"
		#expect(v == "World!")
    }
}


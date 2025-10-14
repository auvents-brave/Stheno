import Testing

@testable import RabFoundation

@Suite("Throttling Property Wrapper") struct ThrottledTests {
    @Test("Value is throttled (does not update immediately)")
    func DidNotUpdated() async throws {
        @Throttled(timeInterval: 99) var v = "Hello"
        v = "World!"
        #expect(v == "Hello")
    }

    @Test("Value updates immediately with zero interval")
    func DidUpdated() async throws {
        @Throttled(timeInterval: 0) var v = "Hello"
        v = "World!"
        #expect(v == "World!")
    }

    @Test("Value remains unchanged after throttling interval (dropped updates)")
    func UpdatesDroppedAfterInterval() async throws {
        @Throttled(timeInterval: 0.05) var v = "Hello"
        // Update the value; current implementation drops the update during the throttling window.
        v = "World!"
        #expect(v == "Hello")

        // Wait slightly longer than the throttling interval; value should still be unchanged.
        try await Task.sleep(nanoseconds: 60_000_000)
        #expect(v == "Hello")
    }
}


import Testing

@testable import RabFoundation

@Suite("Throttling Property Wrapper") struct ThrottledTests {
    @Test("Value is throttled (does not update immediately)")
    func DidNotUpdated() async throws {
        @Throttled var v = "Hello"
        v = "World!"
        #expect(v == "Hello")
    }

    @Test("Value updates immediately with zero interval")
    func DidUpdated() async throws {
        @Throttled(timeInterval: 0) var v = "Hello"
        v = "World!"
        #expect(v == "World!")
    }
}


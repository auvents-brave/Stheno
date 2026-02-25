#if canImport(SwiftUI)
    import SwiftUI
#endif
import Testing

@testable import Stheno

@Suite("Color <-> HTML Hex Conversion")
struct ColorHTMLHexTests {
	@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
    @Test func `Round-trip .red <-> #FF0000`() async throws {
        let color = Color(red: 1, green: 0, blue: 0)
        let html = color.toHTMLHex()
        #expect(html == "#FF0000")
        let color2 = Color(htmlHex: "#FF0000")
        #expect(color2 != nil)
    }

	@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
    @Test func `Round-trip .green <-> #00FF00`() async throws {
        let color = Color(red: 0, green: 1, blue: 0)
        let html = color.toHTMLHex()
        #expect(html == "#00FF00")
        let color2 = Color(htmlHex: "#00FF00")
        #expect(color2 != nil)
    }

	@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
    @Test func `Round-trip .blue <-> #0000FF`() async throws {
        let color = Color(red: 0, green: 0, blue: 1)
        let html = color.toHTMLHex()
        #expect(html == "#0000FF")
        let color2 = Color(htmlHex: "#0000FF")
        #expect(color2 != nil)
    }

	@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
    @Test func `Shorthand #F00`() async throws {
        let color = Color(htmlHex: "#F00")
        #expect(color != nil)
    }

	@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
    @Test func `Invalid hex string returns nil`() async throws {
        let color = Color(htmlHex: "invalid")
        #expect(color == nil)
    }
}

import Testing

@testable import Stheno

#if canImport(SwiftUI)
	import SwiftUI
#endif
#if canImport(UIKit)
	import UIKit
#endif
// Only pull AppKit where it's the active path (pure macOS). On Mac Catalyst
// `canImport(AppKit)` is also true, but importing it alongside `Testing` drags
// in the `_Testing_AppKit` cross-import overlay, which the Catalyst SDK doesn't
// ship — and the NSColor test below is UIKit-gated off there anyway.
#if canImport(AppKit) && !canImport(UIKit)
	import AppKit
#endif

@Suite("Color <-> HTML Hex Conversion")
struct ColorHTMLHexTests {
	@Test func `Round-trip .red <-> #FF0000`() async throws {
		let color = Color(red: 1, green: 0, blue: 0)
		let html = color.toHTMLHex()
		#expect(html == "#FF0000")
		let color2 = Color(htmlHex: "#FF0000")
		#expect(color2 != nil)
	}

	@Test func `Round-trip .green <-> #00FF00`() async throws {
		let color = Color(red: 0, green: 1, blue: 0)
		let html = color.toHTMLHex()
		#expect(html == "#00FF00")
		let color2 = Color(htmlHex: "#00FF00")
		#expect(color2 != nil)
	}

	@Test func `Round-trip .blue <-> #0000FF`() async throws {
		let color = Color(red: 0, green: 0, blue: 1)
		let html = color.toHTMLHex()
		#expect(html == "#0000FF")
		let color2 = Color(htmlHex: "#0000FF")
		#expect(color2 != nil)
	}

	@Test func `Shorthand #F00`() async throws {
		let color = Color(htmlHex: "#F00")
		#expect(color != nil)
	}

	@Test func `Invalid hex string returns nil`() async throws {
		let color = Color(htmlHex: "invalid")
		#expect(color == nil)
	}

	@Test func `Accepts no leading hash and trims whitespace`() {
		#expect(Color(htmlHex: "00FF00") != nil)
		#expect(Color(htmlHex: "  #0000ff  ") != nil)
		#expect(Color(htmlHex: "f00") != nil)
	}

	@Test func `Rejects wrong lengths and out-of-range digits`() {
		#expect(Color(htmlHex: "") == nil)
		#expect(Color(htmlHex: "#FF") == nil)  // 2 digits
		#expect(Color(htmlHex: "#FFFF") == nil)  // 4 digits
		#expect(Color(htmlHex: "#FFFFF") == nil)  // 5 digits
		#expect(Color(htmlHex: "#GGGGGG") == nil)  // non-hex digits
	}

	#if canImport(AppKit) && !canImport(UIKit)
		@Test func `NSColor round-trips through HTML hex`() throws {
			let color = try #require(NSColor(htmlHex: "#3366CC"))
			#expect(color.toHTMLHex() == "#3366CC")
			#expect(color.toHTMLHex(includeHash: false) == "3366CC")
			#expect(NSColor(htmlHex: "not a colour") == nil)
		}
	#endif

	#if canImport(UIKit)
		@Test func `UIColor round-trips through HTML hex`() throws {
			let color = try #require(UIColor(htmlHex: "#3366CC"))
			#expect(color.toHTMLHex() == "#3366CC")
			#expect(color.toHTMLHex(includeHash: false) == "3366CC")
			#expect(UIColor(htmlHex: "not a colour") == nil)
		}
	#endif
}

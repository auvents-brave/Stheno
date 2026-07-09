#if canImport(UIKit)
	public import UIKit
#endif
#if canImport(AppKit)
	public import AppKit
#endif

#if canImport(SwiftUI)
	public import SwiftUI
	/// The platform colour type — SwiftUI's `Color` where available.
	public typealias Color = SwiftUI.Color
#else
	/// A minimal RGB colour used on platforms without SwiftUI.
	public struct Color {
		/// Creates a colour from its red, green and blue components (each in [0, 1]).
		public init(red: Double, green: Double, blue: Double) {
			self.red = red
			self.green = green
			self.blue = blue
		}

		var red: Double
		var green: Double
		var blue: Double
	}
#endif

extension Color {
	/// Initialises a Color from an HTML hex string, strictly parsing #RGB, #RRGGBB, or with no hash.
	///
	/// This initialiser only accepts valid 3 or 6 digit hex strings (with or without a leading `#`).
	/// It expands shorthand (3-digit) notation to full 6-digit hex.
	/// Color is created using the sRGB colour space with full opacity.
	/// Returns `nil` if input is invalid.
	public init?(htmlHex: String) {
		var hex = htmlHex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		if hex.hasPrefix("#") {
			hex.removeFirst()
		}

		let validHexDigits = "0123456789ABCDEF"
		let isValidHex = (hex.count == 3 || hex.count == 6) && hex.allSatisfy { validHexDigits.contains($0) }

		guard isValidHex else { return nil }

		if hex.count == 3 {
			hex = hex.map { "\($0)\($0)" }.joined()
		}

		guard let value = Int(hex, radix: 16) else { return nil }
		let r = Double((value >> 16) & 0xFF) / 255.0
		let g = Double((value >> 8) & 0xFF) / 255.0
		let b = Double(value & 0xFF) / 255.0
		self.init(red: r, green: g, blue: b)
	}

	/// Converts the Color to an HTML hex string (always #RRGGBB, using sRGB colour space strictly).
	///
	/// Extracts the sRGB components of the colour and returns a hex string.
	/// The `includeHash` parameter controls whether the returned string includes a leading `#`.
	/// Returns `nil` if components cannot be extracted.
	public func toHTMLHex(includeHash: Bool = true) -> String {
		#if canImport(SwiftUI)
			#if canImport(UIKit)
				// UIKit: Use sRGB colour space
				let uiColor = UIColor(self)
				var red: CGFloat = 0
				var green: CGFloat = 0
				var blue: CGFloat = 0
				var alpha: CGFloat = 0
				guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return "" }
			#elseif canImport(AppKit)
				let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
				guard let color = nsColor.usingColorSpace(.sRGB) else { return "" }
				let red = color.redComponent
				let green = color.greenComponent
				let blue = color.blueComponent
			#endif
		#else
			let red = self.red
			let green = self.green
			let blue = self.blue
		#endif
		return Stheno.toHTMLHex(
			red: red,
			green: green,
			blue: blue,
			includeHash: includeHash
		)
	}
}

#if canImport(UIKit)
	/// Extensions to `UIColor` for convenient bridging to and from HTML hex strings.
	extension UIColor {
		/// Initialises a `UIColor` from an HTML hex string.
		///
		/// Returns `nil` if the string is not a valid hex colour.
		public convenience init?(htmlHex: String) {
			guard let color = Color(htmlHex: htmlHex) else { return nil }
			self.init(color)
		}

		/// Converts the `UIColor` to an HTML hex string representation.
		///
		/// - Parameter includeHash: A Boolean indicating whether the returned string should include a leading `#`. Default is `true`.
		///
		/// - Returns: A string in the format "#RRGGBB" or "RRGGBB". Returns `nil` if the colour components cannot be extracted.
		public func toHTMLHex(includeHash: Bool = true) -> String? {
			var red: CGFloat = 0
			var green: CGFloat = 0
			var blue: CGFloat = 0
			var alpha: CGFloat = 0
			guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
			return Stheno.toHTMLHex(
				red: red,
				green: green,
				blue: blue,
				includeHash: includeHash
			)
		}
	}

#elseif canImport(AppKit)
	/// Extensions to `NSColor` for convenient bridging to and from HTML hex strings.
	extension NSColor {
		/// Initialises an `NSColor` from an HTML hex string.
		///
		/// Returns `nil` if the string is not a valid hex colour.
		public convenience init?(htmlHex: String) {
			guard let color = Color(htmlHex: htmlHex) else { return nil }
			self.init(color)
		}

		/// Converts the `NSColor` to an HTML hex string representation.
		///
		/// - Parameter includeHash: A Boolean indicating whether the returned string should include a leading `#`. Default is `true`.
		///
		/// - Returns: A string in the format "#RRGGBB" or "RRGGBB". Returns `nil` if the colour components cannot be extracted.
		public func toHTMLHex(includeHash: Bool = true) -> String? {
			guard let cgColor = cgColor.copy(alpha: 1.0), let components = cgColor.components, components.count >= 3
			else { return nil }
			return Stheno.toHTMLHex(
				red: components[0],
				green: components[1],
				blue: components[2],
				includeHash: includeHash
			)
		}
	}
#endif

private func toHTMLHex(red: Double, green: Double, blue: Double, includeHash: Bool = true) -> String {
	let r = Int((red * 255).rounded())
	let g = Int((green * 255).rounded())
	let b = Int((blue * 255).rounded())
	return String(format: "%@%02X%02X%02X", includeHash ? "#" : "", r, g, b)
}

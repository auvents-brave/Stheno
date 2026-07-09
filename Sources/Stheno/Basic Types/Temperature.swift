public import Foundation

/// Supported temperature units.
public enum TemperatureUnit: String, CaseIterable, Sendable {
	case celsius = "°C"
	case fahrenheit = "°F"
}

extension TemperatureUnit {
	/// The temperature unit the user expects for a locale.
	///
	/// Resolution order:
	/// 1. An explicit unit override carried by the locale identifier — the
	///    BCP-47 `mu` keyword (`fr_FR@mu=fahrenhe`, `fr-FR-u-mu-fahrenhe`).
	///    Portable to every platform.
	/// 2. On Apple platforms, `UnitTemperature(forLocale:)`, which also reads
	///    the device-level temperature setting (Language & Region ▸
	///    Temperature) when it is not encoded in the identifier, and knows
	///    per-region data (e.g. Liberia: US measurement system, yet Celsius).
	/// 3. Elsewhere, the locale's measurement system (`.us` ⇒ Fahrenheit).
	///
	/// - Parameter locale: The locale to resolve. Defaults to `Locale.current`.
	/// - Returns: The preferred unit, `.celsius` or `.fahrenheit`.
	public static func preferred(for locale: Locale = .current) -> TemperatureUnit {
		let identifier = locale.identifier.lowercased()
		if identifier.contains("mu=fahrenhe") || identifier.contains("-mu-fahrenhe") { return .fahrenheit }
		if identifier.contains("mu=celsius") || identifier.contains("-mu-celsius") { return .celsius }
		#if canImport(Darwin)
			return UnitTemperature(forLocale: locale) == .fahrenheit ? .fahrenheit : .celsius
		#else
			return locale.measurementSystem == .us ? .fahrenheit : .celsius
		#endif
	}
}

/// A temperature, stored in the unit it was given, with conversion and formatting.
public struct Temperature: Equatable, Sendable {
	/// The numeric temperature, expressed in ``unit``.
	public let value: Double
	/// The unit ``value`` is expressed in.
	public let unit: TemperatureUnit

	/// Creates a temperature with a value and unit.
	public init(value: Double, unit: TemperatureUnit) {
		self.value = value
		self.unit = unit
	}

	/// Converts the temperature to a target unit (one conversion, full precision).
	public func converted(to target: TemperatureUnit) -> Double {
		switch (unit, target) {
		case (.celsius, .fahrenheit): value * 9 / 5 + 32
		case (.fahrenheit, .celsius): (value - 32) * 5 / 9
		default: value
		}
	}

	/// A display format: a target unit with its decimals.
	public enum Format: Sendable {
		case celsius(decimals: Int = 0)
		case fahrenheit(decimals: Int = 0)
	}

	/// Formats the temperature, split into value and unit.
	public func formatted(as format: Format) -> Formatted {
		switch format {
		case .celsius(let d): render(.celsius, d)
		case .fahrenheit(let d): render(.fahrenheit, d)
		}
	}

	private func render(_ target: TemperatureUnit, _ decimals: Int) -> Formatted {
		Formatted(formattedNumber(converted(to: target), decimals: decimals), target.rawValue)
	}
}

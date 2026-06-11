import Foundation
import Testing

@testable import Stheno

@Suite("Temperature Tests")
struct TemperatureTests {
	@Test func `Celsius to Fahrenheit conversion`() {
		let temp = Temperature(value: 0, unit: .celsius)
		#expect(temp.converted(to: .fahrenheit) == 32.0)

		let temp2 = Temperature(value: 100, unit: .celsius)
		#expect(temp2.converted(to: .fahrenheit) == 212.0)

		let temp3 = Temperature(value: -40, unit: .celsius)
		#expect(temp3.converted(to: .fahrenheit) == -40.0)
	}

	@Test func `Fahrenheit to Celsius conversion`() {
		let temp = Temperature(value: 32, unit: .fahrenheit)
		#expect(temp.converted(to: .celsius) == 0.0)

		let temp2 = Temperature(value: 212, unit: .fahrenheit)
		#expect(temp2.converted(to: .celsius) == 100.0)
	}

	@Test func `Temperature preserves original value and unit`() {
		let temp = Temperature(value: 25.5, unit: .celsius)
		#expect(temp.value == 25.5)
		#expect(temp.unit == .celsius)
	}

	@Test func `Temperature formatted output`() {
		let temp = Temperature(value: 20, unit: .celsius)
		let formatted = temp.formatted(as: .fahrenheit())
		#expect(formatted.value == "68")
		#expect(formatted.unit == "°F")
	}

	@Test func `Preferred unit follows the locale's region`() {
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "fr_FR")) == .celsius)
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "en_US")) == .fahrenheit)
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "en_GB")) == .celsius)
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "ja_JP")) == .celsius)
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "es_MX")) == .celsius)
	}

	@Test func `Preferred unit honours an explicit unit override`() {
		// The `mu` keyword is what Apple systems set when the user picks a
		// temperature unit detached from their region.
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "fr_FR@mu=fahrenhe")) == .fahrenheit)
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "fr-FR-u-mu-fahrenhe")) == .fahrenheit)
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "en-US-u-mu-celsius")) == .celsius)
	}

	@Test func `Preferred unit is independent of the measurement system`() {
		// A device can pair any measurement system with any temperature unit:
		// the `mu` keyword always wins over the `ms` keyword.
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "en-US-u-ms-metric-mu-fahrenhe")) == .fahrenheit)  // km + °F
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "fr-FR-u-ms-ussystem-mu-celsius")) == .celsius)  // mi + °C
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "ja-JP-u-mu-fahrenhe")) == .fahrenheit)
	}

	@Test func `Preferred unit follows the measurement system when no unit is set`() {
		// Without an explicit temperature choice, the unit derives from the
		// measurement system the user selected, whatever the region.
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "fr-FR-u-ms-ussystem")) == .fahrenheit)
		#expect(TemperatureUnit.preferred(for: Locale(identifier: "en-US-u-ms-metric")) == .celsius)
	}

	#if canImport(Darwin)
		@Test func `Preferred unit knows regional exceptions (Apple platforms)`() {
			// Liberia uses the US measurement system, yet reads Celsius — only
			// `UnitTemperature(forLocale:)` carries that ICU data.
			#expect(TemperatureUnit.preferred(for: Locale(identifier: "en_LR")) == .celsius)
		}
	#endif
}

@Suite("Temperature Conversion Tests")
struct TemperatureConversionTests {
	@Test func `Same unit returns original value`() {
		let temp = Temperature(value: 21.5, unit: .celsius)
		#expect(temp.converted(to: .celsius) == 21.5)
	}
}

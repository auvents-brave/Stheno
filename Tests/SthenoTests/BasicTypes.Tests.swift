import Foundation
import Testing

@testable import Stheno

// MARK: - Angle Tests

@Suite("Angle Tests")
struct AngleTests {
	@Test("Angle normalizes negative degrees")
	func normalizesNegativeDegrees() {
		let angle = Angle(degrees: -45)
		#expect(angle.value == 315)
	}

	@Test("Angle normalizes over-360 degrees")
	func normalizesOver360() {
		let angle = Angle(degrees: 450)
		#expect(angle.value == 90)
	}

	@Test("Cardinal direction mapping")
	func cardinalMapping() {
		#expect(Angle(degrees: 0).cardinalDirection == .N)
		#expect(Angle(degrees: 45).cardinalDirection == .NE)
		#expect(Angle(degrees: 90).cardinalDirection == .E)
		#expect(Angle(degrees: 225).cardinalDirection == .SW)
	}

	@Test("Cardinal direction from string")
	func cardinalFromString() {
		let angle = Angle(cardinalDirection: " sW ")
		#expect(angle?.value == 225)
	}

	@Test("Formatted angle outputs")
	func formattedOutputs() {
		let angle = Angle(degrees: 30)
		let degrees = angle.formattedDegrees
		#expect(degrees.value == 30)
		#expect(degrees.unit == "°")
		#expect(angle.formattedCardinal == "NE")
	}
}

// MARK: - Distance Tests

@Suite("Distance Tests")
struct DistanceTests {
	@Test("Short distance type (< 300m)")
	func shortDistanceType() {
		let distance = Distance(value: 150, unit: .meters)
		#expect(distance.type == .short)

		let distance2 = Distance(value: 299, unit: .meters)
		#expect(distance2.type == .short)

		let distance3 = Distance(value: 900, unit: .feet)
		#expect(distance3.type == .short)
	}

	@Test("Long distance type (>= 300m)")
	func longDistanceType() {
		let distance = Distance(value: 300, unit: .meters)
		#expect(distance.type == .long)

		let distance2 = Distance(value: 1, unit: .kilometers)
		#expect(distance2.type == .long)

		let distance3 = Distance(value: 1, unit: .miles)
		#expect(distance3.type == .long)
	}

	@Test("Meters to Feet conversion")
	func metersToFeet() {
		let distance = Distance(value: 100, unit: .meters)
		let feet = distance.converted(to: .feet)
		#expect(abs(feet - 328.084) < 0.01)
	}

	@Test("Feet to Meters conversion")
	func feetToMeters() {
		let distance = Distance(value: 1000, unit: .feet)
		let meters = distance.converted(to: .meters)
		#expect(abs(meters - 304.8) < 0.1)
	}

	@Test("Kilometers to Miles conversion")
	func kilometersToMiles() {
		let distance = Distance(value: 1.609344, unit: .kilometers)
		let miles = distance.converted(to: .miles)
		#expect(abs(miles - 1.0) < 0.0001)
	}

	@Test("Kilometers to Nautical Miles conversion")
	func kilometersToNauticalMiles() {
		let distance = Distance(value: 1.852, unit: .kilometers)
		let nm = distance.converted(to: .nauticalMiles)
		#expect(abs(nm - 1.0) < 0.0001)
	}

	@Test("Miles to Kilometers conversion")
	func milesToKilometers() {
		let distance = Distance(value: 1, unit: .miles)
		let km = distance.converted(to: .kilometers)
		#expect(abs(km - 1.609344) < 0.0001)
	}

	@Test("Nautical Miles to Kilometers conversion")
	func nauticalMilesToKilometers() {
		let distance = Distance(value: 50, unit: .nauticalMiles)
		let km = distance.converted(to: .kilometers)
		#expect(abs(km - 92.6) < 0.1)
	}

	@Test("Distance can be initialized with Nautical Miles")
	func initWithNauticalMiles() {
		let distance = Distance(value: 100, unit: .nauticalMiles)
		#expect(distance.value == 100)
		#expect(distance.unit == .nauticalMiles)
	}

	@Test("Distance can be initialized with Meters")
	func initWithMeters() {
		let distance = Distance(value: 250, unit: .meters)
		#expect(distance.value == 250)
		#expect(distance.unit == .meters)
	}

	@Test("Distance can be initialized with Feet")
	func initWithFeet() {
		let distance = Distance(value: 500, unit: .feet)
		#expect(distance.value == 500)
		#expect(distance.unit == .feet)
	}

	@Test("Distance formatted output")
	func formattedOutput() {
		let distance = Distance(value: 10, unit: .kilometers)
		let formatted = distance.formatted(in: .miles)
		#expect(abs(formatted.value - 6.21371) < 0.004)
		#expect(formatted.unit == DistanceUnit.miles.localized)
	}

	@Test("Appropriate units for short distances")
	func appropriateUnitsShort() {
		let distance = Distance(value: 100, unit: .meters)
		let units = distance.appropriateUnitsForShort
		#expect(units.contains(.meters))
		#expect(units.contains(.feet))
		#expect(units.count == 2)
	}

	@Test("Appropriate units for long distances")
	func appropriateUnitsLong() {
		let distance = Distance(value: 5, unit: .kilometers)
		let units = distance.appropriateUnitsForLong
		#expect(units.contains(.kilometers))
		#expect(units.contains(.miles))
		#expect(units.contains(.nauticalMiles))
		#expect(units.count == 3)
	}

	@Test("Round-trip conversion preserves value")
	func roundTripConversion() {
		let original = Distance(value: 100, unit: .kilometers)
		let miles = original.converted(to: .miles)
		let backToKm = Distance(value: miles, unit: .miles).converted(to: .kilometers)
		#expect(abs(backToKm - 100) < 0.0001)
	}

	#if os(WASI)
	@Test("Distance localized units use raw values on WASI")
	func localizedUnitsFallbackOnWasi() {
		#expect(DistanceUnit.meters.localized == "m")
		#expect(DistanceUnit.feet.localized == "ft")
		#expect(DistanceUnit.kilometers.localized == "km")
		#expect(DistanceUnit.miles.localized == "mi")
		#expect(DistanceUnit.nauticalMiles.localized == "nm")
	}
	#endif

	@Test func noName() {
		Distance.noName()
	}
	
}

@Suite("Distance Formatting Tests")
struct DistanceFormattingTests {
	@Test("Adapt long units for short distances")
	func adaptForShortDistances() {
		let distance = Distance(value: 0.2, unit: .kilometers)
		let formatted = distance.formatted(in: .kilometers, adaptForShortDistances: true)
		#expect(formatted.unit == DistanceUnit.meters.localized)
		#expect(formatted.value == 200)
	}

	@Test("Rounding decimals")
	func roundingDecimals() {
		let distance = Distance(value: 1.234, unit: .kilometers)
		let formatted = distance.formatted(in: .kilometers, decimals: 1)
		#expect(formatted.value == 1.2)
	}
}

// MARK: - Speed Tests

@Suite("Speed Tests")
struct SpeedTests {
	@Test("Km/h to MPH conversion")
	func kmhToMph() {
		let speed = Speed(value: 100, unit: .kilometersPerHour)
		let mph = speed.converted(to: .milesPerHour)
		#expect(abs(mph - 62.1371) < 0.001)
	}

	@Test("Km/h to Knots conversion")
	func kmhToKnots() {
		let speed = Speed(value: 100, unit: .kilometersPerHour)
		let knots = speed.converted(to: .knots)
		#expect(abs(knots - 53.9957) < 0.001)
	}

	@Test("Knots to Km/h conversion")
	func knotsToKmh() {
		let speed = Speed(value: 25, unit: .knots)
		let kmh = speed.converted(to: .kilometersPerHour)
		#expect(abs(kmh - 46.3) < 0.1)
	}

	@Test("Speed can be initialized with Knots")
	func initWithKnots() {
		let speed = Speed(value: 50, unit: .knots)
		#expect(speed.value == 50)
		#expect(speed.unit == .knots)
	}

	@Test("MPH to Knots conversion")
	func mphToKnots() {
		let speed = Speed(value: 100, unit: .milesPerHour)
		let knots = speed.converted(to: .knots)
		#expect(abs(knots - 86.8976) < 0.001)
	}

	@Test("Speed formatted output")
	func formattedOutput() {
		let speed = Speed(value: 100, unit: .kilometersPerHour)
		let formatted = speed.formatted(in: .knots)
		#expect(abs(formatted.value - 53.9957) < 0.001)
		#expect(formatted.unit == SpeedUnit.knots.localized)
	}

	@Test("Same unit returns original value")
	func sameUnitConversion() {
		let speed = Speed(value: 75.5, unit: .knots)
		#expect(speed.converted(to: .knots) == 75.5)
	}

	#if os(WASI)
	@Test("Speed localized units use raw values on WASI")
	func localizedUnitsFallbackOnWasi() {
		#expect(SpeedUnit.kilometersPerHour.localized == "km/h")
		#expect(SpeedUnit.milesPerHour.localized == "mph")
		#expect(SpeedUnit.knots.localized == "kn")
	}
	#endif
}

@Suite("Speed Beaufort Tests")
struct SpeedBeaufortTests {
	@Test("Beaufort thresholds from km/h")
	func beaufortThresholdsKmh() {
		#expect(Speed(value: 0.5, unit: .kilometersPerHour).beaufort == .calm)
		#expect(Speed(value: 1.0, unit: .kilometersPerHour).beaufort == .lightAir)
		#expect(Speed(value: 5.9, unit: .kilometersPerHour).beaufort == .lightAir)
		#expect(Speed(value: 6.0, unit: .kilometersPerHour).beaufort == .lightBreeze)
		#expect(Speed(value: 118.0, unit: .kilometersPerHour).beaufort == .hurricane)
	}

	@Test("Beaufort conversion from knots")
	func beaufortFromKnots() {
		let speed = Speed(value: 10, unit: .knots)
		#expect(speed.beaufort == .gentleBreeze)
	}
}

// MARK: - Temperature Tests

@Suite("Temperature Tests")
struct TemperatureTests {
	@Test("Celsius to Fahrenheit conversion")
	func celsiusToFahrenheit() {
		let temp = Temperature(value: 0, unit: .celsius)
		#expect(temp.converted(to: .fahrenheit) == 32.0)

		let temp2 = Temperature(value: 100, unit: .celsius)
		#expect(temp2.converted(to: .fahrenheit) == 212.0)

		let temp3 = Temperature(value: -40, unit: .celsius)
		#expect(temp3.converted(to: .fahrenheit) == -40.0)
	}

	@Test("Fahrenheit to Celsius conversion")
	func fahrenheitToCelsius() {
		let temp = Temperature(value: 32, unit: .fahrenheit)
		#expect(temp.converted(to: .celsius) == 0.0)

		let temp2 = Temperature(value: 212, unit: .fahrenheit)
		#expect(temp2.converted(to: .celsius) == 100.0)
	}

	@Test("Temperature preserves original value and unit")
	func preservesOriginal() {
		let temp = Temperature(value: 25.5, unit: .celsius)
		#expect(temp.value == 25.5)
		#expect(temp.unit == .celsius)
	}

	@Test("Temperature formatted output")
	func formattedOutput() {
		let temp = Temperature(value: 20, unit: .celsius)
		let formatted = temp.formatted(in: .fahrenheit)
		#expect(formatted.value == 68.0)
		#expect(formatted.unit == "°F")
	}
}

@Suite("Temperature Conversion Tests")
struct TemperatureConversionTests {
	@Test("Same unit returns original value")
	func sameUnitConversion() {
		let temp = Temperature(value: 21.5, unit: .celsius)
		#expect(temp.converted(to: .celsius) == 21.5)
	}
}

// MARK: - DateTime Tests

#if canImport(Darwin)
@Suite("DateTime Tests")
struct DateTimeTests {
	@Test("DateTime preserves original date")
	func preservesOriginal() {
		let date = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC
		let dateTime = DateTime(date: date)
			#expect(dateTime.date == date)
			}

	@Test("DateTime can be initialized")
	func initWithLocal() {
		let date = Date()
		let dateTime = DateTime(date: date)
		#expect(dateTime.date == date)
	}

	@Test("DateTime initialization from ISO8601 string (Z)")
	func initFromISO8601UTC() {
		let dateTime = DateTime(iso8601String: "2024-01-23T15:30:00Z")
		#expect(dateTime != nil)
			}

	@Test("DateTime initialization from ISO8601 string (offset)")
	func initFromISO8601Local() {
		let dateTime = DateTime(iso8601String: "2024-01-23T15:30:00+01:00")
		#expect(dateTime != nil)
			}

	@Test("DateTime initialization from invalid ISO8601 string returns nil")
	func initFromInvalidISO8601() {
		let dateTime = DateTime(iso8601String: "invalid-date")
		#expect(dateTime == nil)
	}

	@Test("DateTime formatted output contains date, time, and unit")
	func formattedOutput() {
		let date = Date(timeIntervalSince1970: 1704067200)
		let dateTime = DateTime(date: date)
		let formatted = dateTime.formatted(in: .utc)
		#expect(formatted.date == "2024-01-01")
		#expect(formatted.time == "00:00:00")
		#expect(formatted.unit == " UT")
	}

	@Test("DateTime ISO formatted output UTC")
	func isoFormattedOutputUTC() {
		let date = Date(timeIntervalSince1970: 1704067200)
		let dateTime = DateTime(date: date)
		let isoFormatted = dateTime.formattedISO(in: .utc)
		#expect(isoFormatted.contains("2024-01-01"))
		#expect(isoFormatted.contains("T"))
			}

	@Test("DateTime ISO formatted output Local")
	func isoFormattedOutputLocal() {
		let date = Date(timeIntervalSince1970: 1704067200)
		let dateTime = DateTime(date: date)
		let isoFormatted = dateTime.formattedISO(in: .local)
		#expect(isoFormatted.contains("2024-01-01"))
			}

	@Test("DateTime custom format")
	func customFormat() {
		let date = Date(timeIntervalSince1970: 1704067200)
		let dateTime = DateTime(date: date)
		let formatted = dateTime.formatted(in: .utc, format: "dd/MM/yyyy")
		#expect(formatted.date == "01/01/2024")
		#expect(formatted.time.isEmpty)
	}

	@Test("DateTime stores date")
	func storesDate() {
		let date = Date()
		let dateTime = DateTime(date: date)
			#expect(dateTime.date == date)
	}

	@Test("Round-trip ISO8601 parsing")
	func roundTripISO8601() {
		let originalDate = Date(timeIntervalSince1970: 1704067200)
		let dateTime = DateTime(date: originalDate)
		let isoString = dateTime.formattedISO(in: .utc)

		let parsedDateTime = DateTime(iso8601String: isoString)
		#expect(parsedDateTime != nil)
		// Allow small difference due to fractional seconds precision
		#expect(abs(parsedDateTime!.date.timeIntervalSince(originalDate)) < 1.0)
	}
}

let iso8601Arguments: [(input: String, shouldParseWithSwiftDate: Bool, shouldParseWithISO8601DateFormatter: Bool)] = [
	// Date only
	("2026-01-30", false, false),
	("20260130", false, false),

	// Local time
	("2026-01-30T14:05", false, false),
	("2026-01-30T14:05:09", false, false),
	("2026-01-30T14:05:09.4", false, false),
	("2026-01-30T14:05:09.47", false, false),
	("2026-01-30T14:05:09.472", false, false),

	// UTC (Z)
	("2026-01-30T13:05Z", false, false),
	("2026-01-30T13:05:09Z", true, false), /// DIFF
	("2026-01-30T13:05:09.4Z", true, true),
	("2026-01-30T13:05:09.472Z", true, true),
	("2026-01-30T13:05:09.472839Z", true, true),

	// Timezone offsets
	("2026-01-30T14:05+01:00", false, false),
	("2026-01-30T14:05:09+01:00", true, false), /// DIFF
	("2026-01-30T14:05:09.47+01:00", true, true),
	("2026-01-30T14:05:09.472839+01:00", true, true),
	("2026-01-30T08:05:09-05:00", true, false), /// DIFF

	// Reduced precision
	("2026", false, false),
	("2026-01", false, false),
	("2026-01-30T14", false, false),

	// Compact
	("20260130T140509Z", false, false),
	("20260130T140509.472Z", false, false),

	// ISO-valid but NOT supported by Foundation (comma decimals)
	("2026-01-30T14:05:09,4", false, false),
	("2026-01-30T14:05:09,47", false, false),
	("2026-01-30T13:05:09,472Z", true, false), /// DIFF
	("2026-01-30T14:05:09,472+01:00", true, false), /// DIFF
]

#endif

// MARK: - Edge Cases Tests

@Suite("Edge Cases")
struct EdgeCaseTests {
	@Test("Zero values")
	func zeroValues() {
		let temp = Temperature(value: 0, unit: .celsius)
		#expect(temp.value == 0)

		let distance = Distance(value: 0, unit: .kilometers)
		#expect(distance.value == 0)
		#expect(distance.type == .short) // 0m is considered short

		let speed = Speed(value: 0, unit: .knots)
		#expect(speed.value == 0)
	}

	@Test("Negative temperature")
	func negativeTemperature() {
		let temp = Temperature(value: -273.15, unit: .celsius)
		let fahrenheit = temp.converted(to: .fahrenheit)
		#expect(abs(fahrenheit - -459.67) < 0.01)
	}

	@Test("Very large values")
	func largeValues() {
		let distance = Distance(value: 1000000, unit: .kilometers)
		let miles = distance.converted(to: .miles)
		#expect(miles > 0)
		#expect(distance.type == .long)
	}

	@Test("Precision with small decimals")
	func smallDecimals() {
		let temp = Temperature(value: 0.1, unit: .celsius)
		let fahrenheit = temp.converted(to: .fahrenheit)
		#expect(abs(fahrenheit - 32.18) < 0.01)
	}

	@Test("Distance exactly at 300m threshold")
	func distanceAtThreshold() {
		let distance = Distance(value: 300, unit: .meters)
		#expect(distance.type == .long)

		let distance2 = Distance(value: 299.9, unit: .meters)
		#expect(distance2.type == .short)
	}

	@Test("Very small distances")
	func verySmallDistances() {
		let distance = Distance(value: 0.5, unit: .meters)
		#expect(distance.type == .short)
		let feet = distance.converted(to: .feet)
		#expect(feet > 0)
	}
}

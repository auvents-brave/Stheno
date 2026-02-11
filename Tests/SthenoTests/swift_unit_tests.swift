import Foundation
import Testing

@testable import Stheno

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
        #expect(formatted.unit == "distance.mi")
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
        #expect(formatted.unit == "speed.kn")
    }

    @Test("Same unit returns original value")
    func sameUnitConversion() {
        let speed = Speed(value: 75.5, unit: .knots)
        #expect(speed.converted(to: .knots) == 75.5)
    }
}


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


// MARK: - DateTime Tests

#if os(Darwin)
@Suite("DateTime Tests")
struct DateTimeTests {
    @Test("DateTime preserves original date and type")
    func preservesOriginal() {
        let date = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC
        let dateTime = DateTime(date: date, type: .utc)
        #expect(dateTime.date == date)
        #expect(dateTime.type == .utc)
    }

    @Test("DateTime can be initialized with Local type")
    func initWithLocal() {
        let date = Date()
        let dateTime = DateTime(date: date, type: .local)
        #expect(dateTime.type == .local)
    }

    @Test("DateTime initialization from ISO8601 string UTC")
    func initFromISO8601UTC() {
        let dateTime = DateTime(iso8601String: "2024-01-23T15:30:00Z")
        #expect(dateTime != nil)
        #expect(dateTime?.type == .utc)
    }

    @Test("DateTime initialization from ISO8601 string Local")
    func initFromISO8601Local() {
        let dateTime = DateTime(iso8601String: "2024-01-23T15:30:00Z")
        #expect(dateTime != nil)
        #expect(dateTime?.type == .utc)
    }

    @Test("DateTime initialization from invalid ISO8601 string returns nil")
    func initFromInvalidISO8601() {
        let dateTime = DateTime(iso8601String: "invalid-date")
        #expect(dateTime == nil)
    }

    @Test("DateTime formatted output contains value and unit")
    func formattedOutput() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date, type: .utc)
        let formatted = dateTime.formatted(in: .utc)
        #expect(formatted.value.contains("2024-01-01"))
        #expect(formatted.unit == " UT")
    }

    @Test("DateTime ISO formatted output UTC")
    func isoFormattedOutputUTC() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date, type: .utc)
        let isoFormatted = dateTime.formattedISO(in: .utc)
        #expect(isoFormatted.value.contains("2024-01-01"))
        #expect(isoFormatted.value.contains("T"))
        #expect(isoFormatted.unit == " UT")
    }

    @Test("DateTime ISO formatted output Local")
    func isoFormattedOutputLocal() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date, type: .utc)
        let isoFormatted = dateTime.formattedISO(in: .local)
        #expect(isoFormatted.value.contains("2024-01-01"))
        #expect(isoFormatted.unit == " LT")
    }

    @Test("DateTime custom format")
    func customFormat() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date, type: .utc)
        let formatted = dateTime.formatted(in: .utc, format: "dd/MM/yyyy")
        #expect(formatted.value == "01/01/2024")
    }

    @Test("Converted date returns same date object")
    func convertedDate() {
        let date = Date()
        let dateTime = DateTime(date: date, type: .utc)
        let converted = dateTime.converted(to: .local)
        #expect(converted == date)
    }

    @Test("Round-trip ISO8601 parsing")
    func roundTripISO8601() {
        let originalDate = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: originalDate, type: .utc)
        let isoString = dateTime.formattedISO(in: .utc).value

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

    @Test(arguments: iso8601Arguments)
    func `ISO 8601 parsing with ISO8601DateFormatter` (
        input: String,
		shouldParseWithSwiftDate: Bool,
		shouldParseWithISO8601DateFormatter: Bool
    ) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]

		let d = formatter.date(from: input)
		let parsed = d != nil
		#expect(parsed == shouldParseWithISO8601DateFormatter)

        if parsed {
			let dt = DateTime(iso8601String: input)
            let A = dt?.formattedWithSwiftDate(in: .local)

            print(input + " -> " + A!.value)
        } else {
            print(input + " SYNTAX ERROR")
        }
    }

@Test(arguments: iso8601Arguments)
func `ISO 8601 parsing with SwiftDate` (
	input: String,
	shouldParseWithSwiftDate: Bool,
	shouldParseWithISO8601DateFormatter: Bool
) {
	let dt = DateTime(iso8601String: input)
	let A = dt?.formattedWithSwiftDate(in: .local)
	let parsed = A != nil
	#expect(parsed == shouldParseWithSwiftDate)

	if (parsed) {
		print(A!.value + A!.unit)
	}
}
#endif

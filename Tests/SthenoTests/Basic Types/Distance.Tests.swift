import Foundation
import Testing

@testable import Stheno

@Suite("Distance Tests")
struct DistanceTests {
    @Test func `Short distance type (< 300m)`() {
        let distance = Distance(value: 150, unit: .meters)
        #expect(distance.type == .short)

        let distance2 = Distance(value: 299, unit: .meters)
        #expect(distance2.type == .short)

        let distance3 = Distance(value: 900, unit: .feet)
        #expect(distance3.type == .short)
    }

    @Test func `Long distance type (>= 300m)`() {
        let distance = Distance(value: 300, unit: .meters)
        #expect(distance.type == .long)

        let distance2 = Distance(value: 1, unit: .kilometers)
        #expect(distance2.type == .long)

        let distance3 = Distance(value: 1, unit: .miles)
        #expect(distance3.type == .long)
    }

    @Test func `Meters to Feet conversion`() {
        let distance = Distance(value: 100, unit: .meters)
        let feet = distance.converted(to: .feet)
        #expect(abs(feet - 328.084) < 0.01)
    }

    @Test func `Feet to Meters conversion`() {
        let distance = Distance(value: 1000, unit: .feet)
        let meters = distance.converted(to: .meters)
        #expect(abs(meters - 304.8) < 0.1)
    }

    @Test func `Kilometers to Miles conversion`() {
        let distance = Distance(value: 1.609344, unit: .kilometers)
        let miles = distance.converted(to: .miles)
        #expect(abs(miles - 1.0) < 0.0001)
    }

    @Test func `Kilometers to Nautical Miles conversion`() {
        let distance = Distance(value: 1.852, unit: .kilometers)
        let nm = distance.converted(to: .nauticalMiles)
        #expect(abs(nm - 1.0) < 0.0001)
    }

    @Test func `Miles to Kilometers conversion`() {
        let distance = Distance(value: 1, unit: .miles)
        let km = distance.converted(to: .kilometers)
        #expect(abs(km - 1.609344) < 0.0001)
    }

    @Test func `Nautical Miles to Kilometers conversion`() {
        let distance = Distance(value: 50, unit: .nauticalMiles)
        let km = distance.converted(to: .kilometers)
        #expect(abs(km - 92.6) < 0.1)
    }

    @Test func `Distance can be initialized with Nautical Miles`() {
        let distance = Distance(value: 100, unit: .nauticalMiles)
        #expect(distance.value == 100)
        #expect(distance.unit == .nauticalMiles)
    }

    @Test func `Distance can be initialized with Meters`() {
        let distance = Distance(value: 250, unit: .meters)
        #expect(distance.value == 250)
        #expect(distance.unit == .meters)
    }

    @Test func `Distance can be initialized with Feet`() {
        let distance = Distance(value: 500, unit: .feet)
        #expect(distance.value == 500)
        #expect(distance.unit == .feet)
    }

    @Test func `Distance formatted output`() {
        let distance = Distance(value: 10, unit: .kilometers)
        let formatted = distance.formatted(in: .miles)
        #expect(abs(formatted.value - 6.21371) < 0.004)
        #expect(formatted.unit == DistanceUnit.miles.localized)
    }

    @Test func `Appropriate units for short distances`() {
        let distance = Distance(value: 100, unit: .meters)
        let units = distance.appropriateUnitsForShort
        #expect(units.contains(.meters))
        #expect(units.contains(.feet))
        #expect(units.count == 2)
    }

    @Test func `Appropriate units for long distances`() {
        let distance = Distance(value: 5, unit: .kilometers)
        let units = distance.appropriateUnitsForLong
        #expect(units.contains(.kilometers))
        #expect(units.contains(.miles))
        #expect(units.contains(.nauticalMiles))
        #expect(units.count == 3)
    }

    @Test func `Round-trip conversion preserves value`() {
        let original = Distance(value: 100, unit: .kilometers)
        let miles = original.converted(to: .miles)
        let backToKm = Distance(value: miles, unit: .miles).converted(to: .kilometers)
        #expect(abs(backToKm - 100) < 0.0001)
    }

    #if os(WASI)
    @Test func `Distance localized units use raw values on WASI`() {
        #expect(DistanceUnit.meters.localized == "m")
        #expect(DistanceUnit.feet.localized == "ft")
        #expect(DistanceUnit.kilometers.localized == "km")
        #expect(DistanceUnit.miles.localized == "mi")
        #expect(DistanceUnit.nauticalMiles.localized == "nm")
    }
    #endif

    @Test func `Distance no name`() {
        Distance.noName()
    }
}

@Suite("Distance Formatting Tests")
struct DistanceFormattingTests {
    @Test func `Adapt long units for short distances`() {
        let distance = Distance(value: 0.2, unit: .kilometers)
        let formatted = distance.formatted(in: .kilometers, adaptForShortDistances: true)
        #expect(formatted.unit == DistanceUnit.meters.localized)
        #expect(formatted.value == 200)
    }

    @Test func `Rounding decimals`() {
        let distance = Distance(value: 1.234, unit: .kilometers)
        let formatted = distance.formatted(in: .kilometers, decimals: 1)
        #expect(formatted.value == 1.2)
    }
}

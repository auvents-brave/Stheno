import Foundation
import Testing

@testable import Stheno

@Suite("Speed Tests")
struct SpeedTests {
    @Test func `Km/h to MPH conversion`() {
        let speed = Speed(value: 100, unit: .kilometersPerHour)
        let mph = speed.converted(to: .milesPerHour)
        #expect(abs(mph - 62.1371) < 0.001)
    }

    @Test func `Km/h to Knots conversion`() {
        let speed = Speed(value: 100, unit: .kilometersPerHour)
        let knots = speed.converted(to: .knots)
        #expect(abs(knots - 53.9957) < 0.001)
    }

    @Test func `Knots to Km/h conversion`() {
        let speed = Speed(value: 25, unit: .knots)
        let kmh = speed.converted(to: .kilometersPerHour)
        #expect(abs(kmh - 46.3) < 0.1)
    }

    @Test func `Speed can be initialized with Knots`() {
        let speed = Speed(value: 50, unit: .knots)
        #expect(speed.value == 50)
        #expect(speed.unit == .knots)
    }

    @Test func `MPH to Knots conversion`() {
        let speed = Speed(value: 100, unit: .milesPerHour)
        let knots = speed.converted(to: .knots)
        #expect(abs(knots - 86.8976) < 0.001)
    }

    @Test func `Speed formatted output`() {
        let speed = Speed(value: 100, unit: .kilometersPerHour)
        let formatted = speed.formatted(in: .knots)
        #expect(abs(formatted.value - 53.9957) < 0.001)
        #expect(formatted.unit == SpeedUnit.knots.localized)
    }

    @Test func `Same unit returns original value`() {
        let speed = Speed(value: 75.5, unit: .knots)
        #expect(speed.converted(to: .knots) == 75.5)
    }

    #if os(WASI)
    @Test func `Speed localized units use raw values on WASI`() {
        #expect(SpeedUnit.kilometersPerHour.localized == "km/h")
        #expect(SpeedUnit.milesPerHour.localized == "mph")
        #expect(SpeedUnit.knots.localized == "kn")
    }
    #endif
}

@Suite("Speed Beaufort Tests")
struct SpeedBeaufortTests {
    @Test func `Beaufort thresholds from km/h`() {
        #expect(Speed(value: 0.5, unit: .kilometersPerHour).beaufort == .calm)
        #expect(Speed(value: 1.0, unit: .kilometersPerHour).beaufort == .lightAir)
        #expect(Speed(value: 5.9, unit: .kilometersPerHour).beaufort == .lightAir)
        #expect(Speed(value: 6.0, unit: .kilometersPerHour).beaufort == .lightBreeze)
        #expect(Speed(value: 118.0, unit: .kilometersPerHour).beaufort == .hurricane)
    }

    @Test func `Beaufort conversion from knots`() {
        let speed = Speed(value: 10, unit: .knots)
        #expect(speed.beaufort == .gentleBreeze)
    }
}

import Foundation
import Testing

@testable import Stheno

@Suite("Edge Cases")
struct EdgeCaseTests {
    @Test func `Zero values`() {
        let temp = Temperature(value: 0, unit: .celsius)
        #expect(temp.value == 0)

        let distance = Distance(value: 0, unit: .kilometers)
        #expect(distance.value == 0)
        #expect(distance.metres == 0)

        let speed = Speed(value: 0, unit: .knots)
        #expect(speed.value == 0)
    }

    @Test func `Negative temperature`() {
        let temp = Temperature(value: -273.15, unit: .celsius)
        let fahrenheit = temp.converted(to: .fahrenheit)
        #expect(abs(fahrenheit - -459.67) < 0.01)
    }

    @Test func `Very large values`() {
        let distance = Distance(value: 1_000_000, unit: .kilometers)
        let miles = distance.converted(to: .miles)
        #expect(miles > 0)
        #expect(distance.metres == 1_000_000_000)
    }

    @Test func `Precision with small decimals`() {
        let temp = Temperature(value: 0.1, unit: .celsius)
        let fahrenheit = temp.converted(to: .fahrenheit)
        #expect(abs(fahrenheit - 32.18) < 0.01)
    }

    @Test func `Adaptive metric switches at 1 km`() {
        let belowKm = Distance(value: 999, unit: .meters)
        #expect(belowKm.formatted(as: .adaptiveMetric).unit == "m")

        let atKm = Distance(value: 1000, unit: .meters)
        #expect(atKm.formatted(as: .adaptiveMetric).unit == "km")
    }

    @Test func `Very small distances`() {
        let distance = Distance(value: 0.5, unit: .meters)
        #expect(distance.metres == 0.5)
        let feet = distance.converted(to: .feet)
        #expect(feet > 0)
    }
}

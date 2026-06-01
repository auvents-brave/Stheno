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
        #expect(distance.type == .short)

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
        #expect(distance.type == .long)
    }

    @Test func `Precision with small decimals`() {
        let temp = Temperature(value: 0.1, unit: .celsius)
        let fahrenheit = temp.converted(to: .fahrenheit)
        #expect(abs(fahrenheit - 32.18) < 0.01)
    }

    @Test func `Distance exactly at 300m threshold`() {
        let distance = Distance(value: 300, unit: .meters)
        #expect(distance.type == .long)

        let distance2 = Distance(value: 299.9, unit: .meters)
        #expect(distance2.type == .short)
    }

    @Test func `Very small distances`() {
        let distance = Distance(value: 0.5, unit: .meters)
        #expect(distance.type == .short)
        let feet = distance.converted(to: .feet)
        #expect(feet > 0)
    }
}

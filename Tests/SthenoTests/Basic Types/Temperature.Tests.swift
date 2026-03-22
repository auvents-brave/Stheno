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
        let formatted = temp.formatted(in: .fahrenheit)
        #expect(formatted.value == 68.0)
        #expect(formatted.unit == "°F")
    }
}

@Suite("Temperature Conversion Tests")
struct TemperatureConversionTests {
    @Test func `Same unit returns original value`() {
        let temp = Temperature(value: 21.5, unit: .celsius)
        #expect(temp.converted(to: .celsius) == 21.5)
    }
}

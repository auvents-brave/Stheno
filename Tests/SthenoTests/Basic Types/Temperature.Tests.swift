import Foundation
import Testing

@testable import Stheno

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

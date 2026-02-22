/// Supported temperature units.
public enum TemperatureUnit: String, CaseIterable {
    case celsius = "°C"
    case fahrenheit = "°F"
}

/// Represents a temperature value with conversion and formatting helpers.
public struct Temperature {
    public let value: Double
    public let unit: TemperatureUnit

    /// Creates a temperature with a value and unit.
    public init(value: Double, unit: TemperatureUnit) {
        self.value = value
        self.unit = unit
    }

    /// Converts the temperature to the target unit.
    public func converted(to targetUnit: TemperatureUnit) -> Double {
        switch (unit, targetUnit) {
        case (.celsius, .fahrenheit):
            return value * 9 / 5 + 32
        case (.fahrenheit, .celsius):
            return (value - 32) * 5 / 9
        case (.fahrenheit, .fahrenheit), (.celsius, .celsius):
            return value
        }
    }

    /// Formats the temperature in the target unit.
    public func formatted(in targetUnit: TemperatureUnit) -> (value: Double, unit: String) {
        return (converted(to: targetUnit), targetUnit.rawValue)
    }
}

// MARK: - Examples (Playground)

#if canImport(Playgrounds) && !NO_PLAYGROUND_EXAMPLES
    import Playgrounds

    #Playground {
        let temp = Temperature(value: 22.5, unit: .celsius)
        _ = temp.converted(to: .fahrenheit)
        _ = temp.formatted(in: .fahrenheit)
        let another = Temperature(value: 72, unit: .fahrenheit)
        _ = another.converted(to: .celsius)
        _ = another.formatted(in: .celsius)

        // Temperature
        let tempCelsius = Temperature(value: 20, unit: .celsius)
        _  = tempCelsius.converted(to: .fahrenheit)
        _ = tempCelsius.formatted(in: .fahrenheit)
    }
#endif

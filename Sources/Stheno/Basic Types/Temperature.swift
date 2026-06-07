/// Supported temperature units.
public enum TemperatureUnit: String, CaseIterable, Sendable {
    case celsius = "°C"
    case fahrenheit = "°F"
}

/// A temperature, stored in the unit it was given, with conversion and formatting.
public struct Temperature: Equatable, Sendable {
    public let value: Double
    public let unit: TemperatureUnit

    /// Creates a temperature with a value and unit.
    public init(value: Double, unit: TemperatureUnit) {
        self.value = value
        self.unit = unit
    }

    /// Converts the temperature to a target unit (one conversion, full precision).
    public func converted(to target: TemperatureUnit) -> Double {
        switch (unit, target) {
        case (.celsius, .fahrenheit): value * 9 / 5 + 32
        case (.fahrenheit, .celsius): (value - 32) * 5 / 9
        default: value
        }
    }

    /// A display format: a target unit with its decimals.
    public enum Format: Sendable {
        case celsius(decimals: Int = 0)
        case fahrenheit(decimals: Int = 0)
    }

    /// Formats the temperature, split into value and unit.
    public func formatted(as format: Format) -> Formatted {
        switch format {
        case let .celsius(d): render(.celsius, d)
        case let .fahrenheit(d): render(.fahrenheit, d)
        }
    }

    private func render(_ target: TemperatureUnit, _ decimals: Int) -> Formatted {
        Formatted(formattedNumber(converted(to: target), decimals: decimals), target.rawValue)
    }
}

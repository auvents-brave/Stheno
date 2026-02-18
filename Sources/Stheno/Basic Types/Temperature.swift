enum TemperatureUnit: String, CaseIterable {
    case celsius = "°C"
    case fahrenheit = "°F"
}

struct Temperature {
    let value: Double
    let unit: TemperatureUnit

    init(value: Double, unit: TemperatureUnit) {
        self.value = value
        self.unit = unit
    }

    func converted(to targetUnit: TemperatureUnit) -> Double {
        switch (unit, targetUnit) {
        case (.celsius, .fahrenheit):
            return value * 9 / 5 + 32
        case (.fahrenheit, .celsius):
            return (value - 32) * 5 / 9
        case (.fahrenheit, .fahrenheit), (.celsius, .celsius):
            return value
        }
    }

    func formatted(in targetUnit: TemperatureUnit) -> (value: Double, unit: String) {
        return (converted(to: targetUnit), targetUnit.rawValue)
    }
}

// MARK: - Examples (Playground)

#if canImport(Playgrounds)
    import Playgrounds

    #Playground {
        let temp = Temperature(value: 22.5, unit: .celsius)
        let valueInF = temp.converted(to: .fahrenheit)
        let formattedInF = temp.formatted(in: .fahrenheit)
        let another = Temperature(value: 72, unit: .fahrenheit)
        let valueInC = another.converted(to: .celsius)
        let formattedInC = another.formatted(in: .celsius)

        // Température
        let tempCelsius = Temperature(value: 20, unit: .celsius)
        let tempFahrenheit = tempCelsius.converted(to: .fahrenheit)
        let tempFormatted = tempCelsius.formatted(in: .fahrenheit)
    }
#endif

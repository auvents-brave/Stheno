import Foundation

/// Supported speed units.
enum SpeedUnit: String, CaseIterable {
    case kilometersPerHour = "km/h"
    case milesPerHour = "mph"
    case knots = "kn"

    /// Localized unit label.
    var localized: String {
        #if os(WASI)
        rawValue
        #else
        NSLocalizedString("speed.\(rawValue)", comment: "")
        #endif
    }
}

/// Beaufort wind force scale (0 to 12) based on km/h thresholds.
enum BeaufortScale: Int, CaseIterable {
    case calm = 0
    case lightAir = 1
    case lightBreeze = 2
    case gentleBreeze = 3
    case moderateBreeze = 4
    case freshBreeze = 5
    case strongBreeze = 6
    case highWind = 7
    case gale = 8
    case strongGale = 9
    case storm = 10
    case violentStorm = 11
    case hurricane = 12

    /// Creates a Beaufort scale value from a km/h speed.
    init(kilometersPerHour: Double) {
        switch kilometersPerHour {
        case ..<1: self = .calm
        case 1..<6: self = .lightAir
        case 6..<12: self = .lightBreeze
        case 12..<20: self = .gentleBreeze
        case 20..<29: self = .moderateBreeze
        case 29..<39: self = .freshBreeze
        case 39..<50: self = .strongBreeze
        case 50..<62: self = .highWind
        case 62..<75: self = .gale
        case 75..<89: self = .strongGale
        case 89..<103: self = .storm
        case 103..<118: self = .violentStorm
        default: self = .hurricane
        }
    }
}

/// Represents a speed value with conversion and formatting helpers.
struct Speed {
    let value: Double
    let unit: SpeedUnit

    // Forces Xcode to include keys for Localizable.strings
    private func noName() {
        _ = NSLocalizedString("speed.km/h", value: "km/h", comment: "Kilometers per hour")
        _ = NSLocalizedString("speed.mph", value: "mph", comment: "Miles per hour")
        _ = NSLocalizedString("speed.kn", value: "kn", comment: "Knots")
    }

    /// Creates a speed with a value and unit.
    init(value: Double, unit: SpeedUnit) {
        self.value = value
        self.unit = unit
    }

    /// Converts the speed to the target unit.
    func converted(to targetUnit: SpeedUnit) -> Double {
        if unit == targetUnit {
            return value
        }

        // Conversion vers km/h comme unite intermediaire
        let kmh: Double
        switch unit {
        case .kilometersPerHour:
            kmh = value
        case .milesPerHour:
            kmh = value * 1.609344
        case .knots:
            kmh = value * 1.852
        }

        // Conversion depuis km/h vers l'unite cible
        switch targetUnit {
        case .kilometersPerHour:
            return kmh
        case .milesPerHour:
            return kmh / 1.609344
        case .knots:
            return kmh / 1.852
        }
    }

    /// Formats the speed in the target unit.
    func formatted(in targetUnit: SpeedUnit) -> (value: Double, unit: String) {
        return (converted(to: targetUnit), targetUnit.localized)
    }

    /// Beaufort wind force derived from the speed.
    var beaufort: BeaufortScale {
        let kmh = converted(to: .kilometersPerHour)
        return BeaufortScale(kilometersPerHour: kmh)
    }
}

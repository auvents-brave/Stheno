import Foundation

enum SpeedUnit: String, CaseIterable {
    case kilometersPerHour = "km/h"
    case milesPerHour = "mph"
    case knots = "kn"

    var localized: String {
        NSLocalizedString("speed.\(rawValue)", comment: "")
    }
}

struct Speed {
    let value: Double
    let unit: SpeedUnit

    // Forces Xcode to include keys for Localizable.strings
    private func noName() {
        _ = NSLocalizedString("speed.km/h", value: "km/h", comment: "Kilometers per hour")
        _ = NSLocalizedString("speed.mph", value: "mph", comment: "Miles per hour")
        _ = NSLocalizedString("speed.kn", value: "kn", comment: "Knots")
    }

    init(value: Double, unit: SpeedUnit) {
        self.value = value
        self.unit = unit
    }

    func converted(to targetUnit: SpeedUnit) -> Double {
        if unit == targetUnit {
            return value
        }

        // Conversion vers km/h comme unité intermédiaire
        let kmh: Double
        switch unit {
        case .kilometersPerHour:
            kmh = value
        case .milesPerHour:
            kmh = value * 1.609344
        case .knots:
            kmh = value * 1.852
        }

        // Conversion depuis km/h vers l'unité cible
        switch targetUnit {
        case .kilometersPerHour:
            return kmh
        case .milesPerHour:
            return kmh / 1.609344
        case .knots:
            return kmh / 1.852
        }
    }

    func formatted(in targetUnit: SpeedUnit) -> (value: Double, unit: String) {
        return (converted(to: targetUnit), targetUnit.localized)
    }
}

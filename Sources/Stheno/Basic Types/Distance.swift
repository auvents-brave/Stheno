import Foundation

enum DistanceUnit: String, CaseIterable {
    case meters = "m"
    case feet = "ft"
    case kilometers = "km"
    case miles = "mi"
    case nauticalMiles = "nm"

    var localized: String {
        NSLocalizedString("distance.\(rawValue)", comment: "")
    }
}

enum DistanceType {
    case short
    case long
}

struct Distance {
    let value: Double
    let unit: DistanceUnit

    // Forces Xcode to include keys for Localizable.strings
    private func noName() {
        _ = NSLocalizedString("distance.m", value: "m", comment: "Meters")
        _ = NSLocalizedString("distance.ft", value: "ft", comment: "Feet")
        _ = NSLocalizedString("distance.km", value: "km", comment: "Kilometers")
        _ = NSLocalizedString("distance.mi", value: "mi", comment: "Miles")
        _ = NSLocalizedString("distance.nm", value: "nm", comment: "Nautical Miles")
    }

    init(value: Double, unit: DistanceUnit) {
        self.value = value
        self.unit = unit
    }

    var type: DistanceType {
        convertedToMeters() < 300 ? .short : .long
    }

    private func convertedToMeters() -> Double {
        switch unit {
        case .meters:
            return value
        case .feet:
            return value * 0.3048
        case .kilometers:
            return value * 1000
        case .miles:
            return value * 1609.344
        case .nauticalMiles:
            return value * 1852
        }
    }

    func converted(to targetUnit: DistanceUnit) -> Double {
        if unit == targetUnit {
            return value
        }

        let meters = convertedToMeters()

        switch targetUnit {
        case .meters:
            return meters
        case .feet:
            return meters / 0.3048
        case .kilometers:
            return meters / 1000
        case .miles:
            return meters / 1609.344
        case .nauticalMiles:
            return meters / 1852
        }
    }

    func formatted(in targetUnit: DistanceUnit, decimals: Int = 2, adaptForShortDistances: Bool = false) -> (value: Double, unit: String) {
        var cvt = converted(to: targetUnit)
        var adaptedUnit = targetUnit
        let isShort = type == .short

        if adaptForShortDistances && isShort && appropriateUnitsForLong.contains(targetUnit) {
            switch targetUnit {
            case .kilometers:
                cvt = converted(to: .meters)
                adaptedUnit = .meters
            case .miles:
                cvt = converted(to: .feet)
                adaptedUnit = .feet
            case .nauticalMiles:
                cvt = converted(to: .meters)
                adaptedUnit = .meters
            default:
                break
            }
        }

        // Correctly round the value to specified decimal places
        let multiplier = pow(10.0, Double(decimals))
        let roundedCvt = (cvt * multiplier).rounded() / multiplier

        return (roundedCvt, adaptedUnit.localized)
    }

    var appropriateUnitsForShort: [DistanceUnit] {
        [.meters, .feet]
    }

    var appropriateUnitsForLong: [DistanceUnit] {
        [.kilometers, .miles, .nauticalMiles]
    }
}

// MARK: - Examples (Playground)

#if canImport(Playgrounds)
    import Playgrounds

    #Playground {
        let a = Distance(value: 18, unit: .kilometers).converted(to: .miles) // 11,18468146027201
        let b = Distance(value: a, unit: .miles).converted(to: .meters) // 18 000
        let c = Distance(value: b, unit: .meters).converted(to: .nauticalMiles) // 9,719222462203025

        let d = Distance(value: 1.212, unit: .kilometers).formatted(in: .meters) // 1212
        let e = Distance(value: 1.212, unit: .kilometers).formatted(in: .nauticalMiles, decimals: 1) // 0,7 (0,6544276457883369)
        let f = Distance(value: 0.2, unit: .kilometers).formatted(in: .kilometers, adaptForShortDistances: true) // 200 m
        let g = Distance(value: 0.15, unit: .nauticalMiles).formatted(in: .nauticalMiles, decimals: 0, adaptForShortDistances: true) // 278 m (277,8)
    }
#endif

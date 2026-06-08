/// Supported speed units.
public enum SpeedUnit: String, CaseIterable, Sendable {
    case kilometersPerHour = "km/h"
    case milesPerHour = "mph"
    case knots = "kn"

    /// Kilometres per hour for one unit.
    var kmhPerUnit: Double {
        switch self {
        case .kilometersPerHour: 1
        case .milesPerHour: 1.609344
        case .knots: 1.852
        }
    }
}

/// Beaufort wind force scale (0 to 12), from km/h thresholds.
public enum BeaufortScale: Int, CaseIterable, Sendable {
    case calm = 0, lightAir, lightBreeze, gentleBreeze, moderateBreeze, freshBreeze
    case strongBreeze, highWind, gale, strongGale, storm, violentStorm, hurricane

    /// Creates a Beaufort force from a km/h speed.
    public init(kilometersPerHour kmh: Double) {
        switch kmh {
        case ..<1: self = .calm
        case 1 ..< 6: self = .lightAir
        case 6 ..< 12: self = .lightBreeze
        case 12 ..< 20: self = .gentleBreeze
        case 20 ..< 29: self = .moderateBreeze
        case 29 ..< 39: self = .freshBreeze
        case 39 ..< 50: self = .strongBreeze
        case 50 ..< 62: self = .highWind
        case 62 ..< 75: self = .gale
        case 75 ..< 89: self = .strongGale
        case 89 ..< 103: self = .storm
        case 103 ..< 118: self = .violentStorm
        default: self = .hurricane
        }
    }
}

/// A speed, stored in the unit it was given, with conversion and formatting.
public struct Speed: Equatable, Sendable {
    /// The speed value, expressed in `unit`.
    public let value: Double
    /// The unit `value` is expressed in.
    public let unit: SpeedUnit

    /// Creates a speed with a value and unit.
    public init(value: Double, unit: SpeedUnit) {
        self.value = value
        self.unit = unit
    }

    /// The speed in km/h.
    public var kilometersPerHour: Double { value * unit.kmhPerUnit }

    /// Converts the speed to a target unit (one conversion, full precision).
    public func converted(to target: SpeedUnit) -> Double {
        unit == target ? value : kilometersPerHour / target.kmhPerUnit
    }

    /// Beaufort wind force for this speed.
    public var beaufort: BeaufortScale { BeaufortScale(kilometersPerHour: kilometersPerHour) }

    /// A display format: a target unit with decimals, or the Beaufort force.
    public enum Format: Sendable {
        case kilometersPerHour(decimals: Int = 0)
        case milesPerHour(decimals: Int = 0)
        case knots(decimals: Int = 0)
        case beaufort
    }

    /// Formats the speed, split into value and unit.
    public func formatted(as format: Format) -> Formatted {
        switch format {
        case let .kilometersPerHour(d): render(.kilometersPerHour, d)
        case let .milesPerHour(d): render(.milesPerHour, d)
        case let .knots(d): render(.knots, d)
        case .beaufort: Formatted(String(beaufort.rawValue), "Bft")
        }
    }

    private func render(_ target: SpeedUnit, _ decimals: Int) -> Formatted {
        Formatted(formattedNumber(converted(to: target), decimals: decimals), target.rawValue)
    }
}

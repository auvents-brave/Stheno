/// Supported distance units.
public enum DistanceUnit: String, CaseIterable, Sendable {
	case meters = "m"
	case feet = "ft"
	case kilometers = "km"
	case miles = "mi"
	case nauticalMiles = "nm"

	/// Metres per one unit.
	var metresPerUnit: Double {
		switch self {
		case .meters: 1
		case .feet: 0.3048
		case .kilometers: 1000
		case .miles: 1609.344
		case .nauticalMiles: 1852
		}
	}
}

/// A distance, stored in the unit it was given, with conversion and formatting.
public struct Distance: Equatable, Sendable {
	/// The numeric distance, expressed in ``unit``.
	public let value: Double
	/// The unit ``value`` is expressed in.
	public let unit: DistanceUnit

	/// Creates a distance with a value and unit.
	public init(value: Double, unit: DistanceUnit) {
		self.value = value
		self.unit = unit
	}

	/// The distance in metres.
	public var metres: Double { value * unit.metresPerUnit }

	/// Converts the distance to a target unit (one conversion, full precision).
	public func converted(to target: DistanceUnit) -> Double {
		unit == target ? value : metres / target.metresPerUnit
	}

	/// A display format: a target unit with its decimals, or an adaptive choice
	/// that drops to a short unit (metres / feet) below 1 km / 1 mile / 0.5 nm.
	public enum Format: Sendable {
		case meters(decimals: Int = 0)
		case feet(decimals: Int = 0)
		case kilometers(decimals: Int = 2)
		case miles(decimals: Int = 2)
		case nauticalMiles(decimals: Int = 2)
		/// Metres below 1 km, otherwise kilometres.
		case adaptiveMetric
		/// Feet below 1 mile, otherwise miles.
		case adaptiveImperial
		/// Metres below 0.5 nm, otherwise nautical miles.
		case adaptiveNautical
	}

	/// Formats the distance, split into value and unit.
	public func formatted(as format: Format) -> Formatted {
		switch format {
		case .meters(let d): render(.meters, d)
		case .feet(let d): render(.feet, d)
		case .kilometers(let d): render(.kilometers, d)
		case .miles(let d): render(.miles, d)
		case .nauticalMiles(let d): render(.nauticalMiles, d)
		case .adaptiveMetric:
			metres < 1000 ? render(.meters, 0) : render(.kilometers, 2)
		case .adaptiveImperial:
			metres < 1609.344 ? render(.feet, 0) : render(.miles, 2)
		case .adaptiveNautical:
			metres < 926 ? render(.meters, 0) : render(.nauticalMiles, 2)
		}
	}

	private func render(_ target: DistanceUnit, _ decimals: Int) -> Formatted {
		Formatted(formattedNumber(converted(to: target), decimals: decimals), target.rawValue)
	}
}

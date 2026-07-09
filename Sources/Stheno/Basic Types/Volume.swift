public import Foundation

/// Supported volume units.
public enum VolumeUnit: String, CaseIterable, Sendable {
	case liters = "L"
	case cubicMeters = "m³"
	case usGallons = "gal"
	case imperialGallons = "gal Imp."

	/// Litres per one of this unit (the conversion pivot).
	var litres: Double {
		switch self {
		case .liters: 1
		case .cubicMeters: 1000
		case .usGallons: 3.785411784
		case .imperialGallons: 4.54609
		}
	}
}

extension VolumeUnit {
	/// The volume unit the user expects for a locale.
	///
	/// There is no device-level volume override (unlike temperature), so the
	/// unit derives from the measurement system: US ⇒ US gallons, UK ⇒
	/// imperial gallons, metric ⇒ litres. On Apple platforms,
	/// `UnitVolume(forLocale:)` is used instead, which also knows per-region
	/// exceptions (e.g. Myanmar and Liberia read litres despite non-metric
	/// measurement systems).
	///
	/// - Parameter locale: The locale to resolve. Defaults to `Locale.current`.
	/// - Returns: The preferred unit — `.liters`, `.usGallons` or `.imperialGallons`.
	public static func preferred(for locale: Locale = .current) -> VolumeUnit {
		#if canImport(Darwin)
			let unit = UnitVolume(forLocale: locale)
			if unit == .gallons { return .usGallons }
			if unit == .imperialGallons { return .imperialGallons }
			return .liters
		#else
			if locale.measurementSystem == .us { return .usGallons }
			if locale.measurementSystem == .uk { return .imperialGallons }
			return .liters
		#endif
	}
}

/// A volume, stored in the unit it was given, with conversion and formatting.
public struct Volume: Equatable, Sendable {
	/// The numeric volume, expressed in ``unit``.
	public let value: Double
	/// The unit ``value`` is expressed in.
	public let unit: VolumeUnit

	/// Creates a volume with a value and unit.
	public init(value: Double, unit: VolumeUnit) {
		self.value = value
		self.unit = unit
	}

	/// Converts the volume to a target unit (one conversion, full precision).
	public func converted(to target: VolumeUnit) -> Double {
		value * unit.litres / target.litres
	}

	/// A display format: a target unit with its decimals.
	public enum Format: Sendable {
		case liters(decimals: Int = 0)
		case cubicMeters(decimals: Int = 1)
		case usGallons(decimals: Int = 0)
		case imperialGallons(decimals: Int = 0)
	}

	/// Formats the volume, split into value and unit.
	public func formatted(as format: Format) -> Formatted {
		switch format {
		case .liters(let d): render(.liters, d)
		case .cubicMeters(let d): render(.cubicMeters, d)
		case .usGallons(let d): render(.usGallons, d)
		case .imperialGallons(let d): render(.imperialGallons, d)
		}
	}

	private func render(_ target: VolumeUnit, _ decimals: Int) -> Formatted {
		Formatted(formattedNumber(converted(to: target), decimals: decimals), target.rawValue)
	}
}

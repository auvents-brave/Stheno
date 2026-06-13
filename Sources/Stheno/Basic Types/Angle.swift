/// Compass directions for 16-point cardinal and intercardinal headings.
public enum CardinalDirection: String, CaseIterable, Sendable {
	case N, NNE, NE, ENE
	case E, ESE, SE, SSE
	case S, SSW, SW, WSW
	case W, WNW, NW, NNW

	/// The heading angle in degrees for this direction.
	public var degrees: Double { Double(Self.allCases.firstIndex(of: self) ?? 0) * 22.5 }

	/// The closest 16-point direction for a degree value.
	public init(degrees: Double) {
		let normalized = Angle(degrees: degrees).value
		let index = Int((normalized / 22.5).rounded()) % 16
		self = Self.allCases[index]
	}

	/// Creates a direction from a string like "N" or "SW".
	public init?(string: String) {
		self.init(rawValue: string.uppercased().filter { !$0.isWhitespace })
	}
}

/// An angle in degrees, normalised to [0, 360).
public struct Angle: Equatable, Sendable {
	public let value: Double

	/// Creates a normalised angle from degrees.
	public init(degrees: Double) {
		let normalized = degrees.truncatingRemainder(dividingBy: 360)
		value = normalized >= 0 ? normalized : normalized + 360
	}

	/// Creates an angle from a cardinal direction string, when one matches.
	public init?(cardinalDirection: String) {
		guard let direction = CardinalDirection(string: cardinalDirection) else { return nil }
		value = direction.degrees
	}

	/// The closest 16-point cardinal direction.
	public var cardinalDirection: CardinalDirection { CardinalDirection(degrees: value) }

	/// A display format: numeric degrees, or a cardinal direction.
	public enum Format: Sendable {
		case degrees(decimals: Int = 0)
		case cardinal
	}

	/// Formats the angle, split into value and unit (the cardinal form has no unit).
	public func formatted(as format: Format) -> Formatted {
		switch format {
		case .degrees(let d): Formatted(formattedNumber(value, decimals: d), "°")
		case .cardinal: Formatted(cardinalDirection.rawValue)
		}
	}
}

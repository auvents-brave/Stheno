enum CardinalDirection: String, CaseIterable {
    case N, NNE, NE, ENE
    case E, ESE, SE, SSE
    case S, SSW, SW, WSW
    case W, WNW, NW, NNW

    var degrees: Double {
        switch self {
        case .N: return 0
        case .NNE: return 22.5
        case .NE: return 45
        case .ENE: return 67.5
        case .E: return 90
        case .ESE: return 112.5
        case .SE: return 135
        case .SSE: return 157.5
        case .S: return 180
        case .SSW: return 202.5
        case .SW: return 225
        case .WSW: return 247.5
        case .W: return 270
        case .WNW: return 292.5
        case .NW: return 315
        case .NNW: return 337.5
        }
    }

    init(degrees: Double) {
		switch Angle(degrees: degrees).value {
        case 337.5 ..< 360, 0 ..< 22.5: self = .N
        case 22.5 ..< 67.5: self = .NE
        case 67.5 ..< 112.5: self = .E
        case 112.5 ..< 157.5: self = .SE
        case 157.5 ..< 202.5: self = .S
        case 202.5 ..< 247.5: self = .SW
        case 247.5 ..< 292.5: self = .W
        case 292.5 ..< 337.5: self = .NW
        default: self = .N
        }
    }

    init?(string: String) {
        let normalized = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        self.init(rawValue: normalized)
    }
}

struct Angle {
	let value: Double

	init(degrees: Double) {
		let normalized = degrees.truncatingRemainder(dividingBy: 360)
		value = normalized >= 0 ? normalized : normalized + 360
	}

	init?(cardinalDirection: String) {
		guard let direction = CardinalDirection(string: cardinalDirection) else {
			return nil
		}
		value = direction.degrees
	}

	var cardinalDirection: CardinalDirection? {
		CardinalDirection(degrees: value)
	}

	var formattedDegrees: (value: Double, unit: String) {
		DegreesFormat.format(self)
	}

	var formattedCardinal: String? {
		CardinalFormat.format(self)
	}

	protocol DirectionFormat {
		associatedtype Output
		static func format(_ value: Angle) -> Output
	}

	struct DegreesFormat: DirectionFormat {
		static func format(_ value: Angle) -> (Double, String) {
			(value.value, "°")
		}
	}

	struct CardinalFormat: DirectionFormat {
		static func format(_ value: Angle) -> String? {
			value.cardinalDirection?.rawValue
		}
	}

	func formatted<F: DirectionFormat>(as _: F.Type) -> F.Output {
		F.format(self)

	}
}

#if canImport(Playgrounds)
import Playgrounds

#Playground {
		// Initialize with degrees
	let a = Angle(degrees: 52)
	print(a.formatted(as: Angle.DegreesFormat.self)) // (value: 52.0, unit: "°")
	print(a.formatted(as: Angle.CardinalFormat.self) ?? "") // "NE"
	print(a.cardinalDirection?.rawValue ?? "") // "NE"

		// Initialize with cardinal direction
	let b = Angle(cardinalDirection: "NW")
	dump(b?.formatted(as: Angle.DegreesFormat.self)) // (value: 315.0, unit: "°")
	print(b?.cardinalDirection?.rawValue ?? "") // "NW"

		// Large degree values
	let c = Angle(degrees: 375)
	print(c.formatted(as: Angle.DegreesFormat.self)) // (value: 15.0, unit: "°")

		// Formatting as cardinal direction
	let d = Angle(degrees: 92)
	print(d.formatted(as: Angle.CardinalFormat.self) ?? "") // "E"

		// Negative degrees
	let e = Angle(degrees: -45)
	print(e.formatted(as: Angle.DegreesFormat.self)) // (value: 315.0, unit: "°")
}
#endif

/// Represents the four cardinal points (N, S, E, W).
enum CardinalPoint: String {
    case north = "N"
    case south = "S"
    case east = "E"
    case west = "W"
}

/// Structure representing geographical coordinates (latitude and longitude).
public struct Coordinate: Equatable {
    /// Latitude in decimal degrees. North is positive, south is negative.
    public var latitude: Double
    /// Longitude in decimal degrees. East is positive, west is negative.
    public var longitude: Double

    /// Initialises coordinates with given latitude and longitude (in decimal degrees).
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Initialises coordinates with direction indicators for latitude and longitude.
    /// - Parameters:
    ///   - latitude: The latitude value in degrees.
    ///   - ns: "N" for north, "S" for south.
    ///   - longitude: The longitude value in degrees.
    ///   - ew: "E" for east, "W" for west.
    public init(latitude: Double, ns: String, longitude: Double, ew: String) {
        let cp1 = CardinalPoint(rawValue: ns) ?? .north
        let cp2 = CardinalPoint(rawValue: ew) ?? .east

        self.latitude = cp1 == .south ? latitude * -1 : latitude
        self.longitude = cp2 == .west ? longitude * -1 : longitude
    }

    /// Latitude in radians.
    public var latitudeRadians: Double {
        return latitude * .pi / 180
    }

    /// Longitude in radians.
    public var longitudeRadians: Double {
        return longitude * .pi / 180
    }

    /// Calculates the great-circle distance to another point using the Haversine formula.
    ///
    /// - Parameters:
    ///   - to: The destination coordinates.
    /// - Returns: The distance in kilometres between the two points.
    public func distance(to: Coordinate) -> Double {
        Geo.distance(from: self, to: to)
    }

    /// Returns true if latitude and longitude values are within valid ranges.
    public func isValid() -> Bool {
        return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180
    }
}

// MARK: - Formatting

public extension Coordinate {
    /// A coordinate display format.
    enum Format: Sendable {
        /// Decimal degrees — "43.74° N".
        case decimal(decimals: Int = 2)
        /// Degrees and decimal minutes — "43°44.3' N".
        case degreesMinutes(decimals: Int = 1)
        /// Degrees, minutes and seconds — "43°44'20" N".
        case degreesMinutesSeconds
    }

    /// Formats latitude and longitude as separate strings, each ending in its
    /// hemisphere letter — so the caller lays them out on one line or two.
    func formatted(as format: Format) -> (latitude: String, longitude: String) {
        (Coordinate.component(latitude, positive: "N", negative: "S", format),
         Coordinate.component(longitude, positive: "E", negative: "W", format))
    }

    private static func component(_ value: Double, positive: String, negative: String, _ format: Format) -> String {
        let hemisphere = value >= 0 ? positive : negative
        let magnitude = abs(value)
        switch format {
        case let .decimal(d):
            return "\(formattedNumber(magnitude, decimals: d))° \(hemisphere)"
        case let .degreesMinutes(d):
            let degrees = Int(magnitude)
            let minutes = (magnitude - Double(degrees)) * 60
            return "\(degrees)°\(formattedNumber(minutes, decimals: d))' \(hemisphere)"
        case .degreesMinutesSeconds:
            let degrees = Int(magnitude)
            let minutesFull = (magnitude - Double(degrees)) * 60
            let minutes = Int(minutesFull)
            let seconds = (minutesFull - Double(minutes)) * 60
            return "\(degrees)°\(minutes)'\(formattedNumber(seconds, decimals: 0))\" \(hemisphere)"
        }
    }
}

#if canImport(CoreLocation)
    public import CoreLocation

    /// Convenience interop for converting a ``Coordinate`` into CoreLocation coordinates.
    extension CLLocationCoordinate2D {
        /// Creates a CoreLocation coordinate from a ``Coordinate`` value.
        /// - Parameter fix: The source coordinate to convert.
        public init(_ fix: Coordinate) {
            self.init(
                latitude: fix.latitude,
                longitude: fix.longitude
            )
        }
    }
#endif

// MARK: - Examples (Playground)

#if canImport(Playgrounds) && !NO_PLAYGROUND_EXAMPLES
    import Playgrounds

    @available(iOS 13, tvOS 13, watchOS 6, *)
    #Playground {
        _ = CLLocationCoordinate2D(Coordinate(latitude: 43.739, longitude: 7.425))
    }
#endif

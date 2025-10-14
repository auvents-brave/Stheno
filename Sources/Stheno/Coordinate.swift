import Foundation

/// Represents the four cardinal points (N, S, E, W).
enum CardinalPoint: String {
    case north = "N"
    case south = "S"
    case east = "E"
    case west = "W"
}

/// Structure representing geographical coordinates (latitude and longitude).
public struct Coordinate {
    /// Latitude in decimal degrees. North is positive, south is negative.
    var latitude: Double
    /// Longitude in decimal degrees. East is positive, west is negative.
    var longitude: Double

    /// Initializes coordinates with given latitude and longitude (in decimal degrees).
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Initializes coordinates with direction indicators for latitude and longitude.
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

    /// Returns true if latitude and longitude values are within valid ranges.
    public func isValid() -> Bool {
        return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180
    }
}

#if canImport(CoreLocation)
    import CoreLocation

    extension CLLocationCoordinate2D {
        public init(_ fix: Coordinate) {
            self.init(
                latitude: fix.latitude,
                longitude: fix.longitude
            )
        }
    }
#endif

import Foundation

/// Utility functions for geographic calculations (distance, bearings, etc.)
public struct Geo {
    static let earthRadiusKm = 6371.0

    /// Calculates the great-circle distance between two points using the Haversine formula.
    ///
    /// - Parameters:
    ///   - from: The starting coordinates.
    ///   - to: The destination coordinates.
    /// - Returns: The distance in kilometers between the two points.
    public static func distance(from: Coordinate, to: Coordinate) -> Double {
        let dLat = to.latitudeRadians - from.latitudeRadians
        let dLon = to.longitudeRadians - from.longitudeRadians

        let a = pow(sin(dLat / 2), 2)
            + cos(from.latitudeRadians) * cos(to.latitudeRadians) * pow(sin(dLon / 2), 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusKm * c
    }

    /// Calculates the total distance (in kilometers) along a series of geographic coordinates.
    ///
    /// - Parameter points: An ordered array of coordinates representing the path.
    /// - Returns: The total distance in kilometers by summing the distances between each consecutive pair of points.
    public static func totalDistance(points: [Coordinate]) -> Double {
        guard points.count >= 2 else {
            return 0.0
        }

        var total = 0.0
        for i in 0 ..< (points.count - 1) {
            total += distance(from: points[i], to: points[i + 1])
        }

        return total
    }

    /// Calculates the initial bearing (forward azimuth) from the starting point to the destination.
    /// - Parameters:
    ///   - from: The starting coordinates.
    ///   - to: The destination coordinates.
    /// - Returns: The bearing in degrees from North (0° to 360°).
    public static func initialBearing(from: Coordinate, to: Coordinate) -> Double {
        let y = sin(to.longitudeRadians - from.longitudeRadians) * cos(to.latitudeRadians)
        let x = cos(from.latitudeRadians) * sin(to.latitudeRadians)
            - sin(from.latitudeRadians) * cos(to.latitudeRadians) * cos(to.longitudeRadians - from.longitudeRadians)

        let bearingRadians = atan2(y, x)
        let bearingDegrees = bearingRadians * 180 / .pi
        return (bearingDegrees + 360).truncatingRemainder(dividingBy: 360)
    }
}

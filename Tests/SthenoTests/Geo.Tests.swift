import Testing

@testable import Stheno

@Suite("Geo Utility Functions")
struct GeoTests {
    @Test("Great-circle distance between the same point is zero")
    func zeroDistance() async throws {
        let a = Coordinate(latitude: 0, longitude: 0)
        #expect(Geo.distance(from: a, to: a) == 0)
    }

    @Test("Distance between two known points (London-Paris)")
    func londonToParisDistance() async throws {
        let london = Coordinate(latitude: 51.5074, longitude: -0.1278)
        let paris = Coordinate(latitude: 48.8566, longitude: 2.3522)
        let d = Geo.distance(from: london, to: paris)
        // Accept within ±1km tolerance (actual ~343.5km)
        #expect(abs(d - 343.5) < 1.0, "London to Paris distance should be about 343.5km")
    }

    @Test("totalDistance with a linear path")
    func linearTotalDistance() async throws {
        let points = [
            Coordinate(latitude: 0, longitude: 0),
            Coordinate(latitude: 0, longitude: 1),
            Coordinate(latitude: 0, longitude: 2),
        ]
        let dist = Geo.totalDistance(points: points)
        // Each segment should be about 111.32 km at the equator
        #expect(abs(dist - 222.64) < 1.0)
    }

    @Test("initialBearing returns North for due north")
    func northBearing() async throws {
        let from = Coordinate(latitude: 0, longitude: 0)
        let to = Coordinate(latitude: 10, longitude: 0)
        let b = Geo.initialBearing(from: from, to: to)
        #expect(abs(b - 0) < 0.01)
    }

    @Test("initialBearing returns East for due east")
    func eastBearing() async throws {
        let from = Coordinate(latitude: 0, longitude: 0)
        let to = Coordinate(latitude: 0, longitude: 10)
        let b = Geo.initialBearing(from: from, to: to)
        #expect(abs(b - 90) < 0.01)
    }
}

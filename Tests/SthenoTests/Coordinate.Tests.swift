import Testing

@testable import RabFoundation

@Suite("Coordinate Struct")
struct CoordinateTests {
    @Test("Initializer stores latitude and longitude values correctly")
    func initLatitudeLongitude() async throws {
        let c = Coordinate(latitude: 42.0, longitude: -71.0)
        #expect(c.latitude == 42.0)
        #expect(c.longitude == -71.0)
    }
    
    @Test("Initializer with direction flips values appropriately")
    func initWithDirections() async throws {
        let c = Coordinate(latitude: 23.5, ns: "S", longitude: 46.6, ew: "W")
        #expect(c.latitude == -23.5)
        #expect(c.longitude == -46.6)
        let c2 = Coordinate(latitude: 10, ns: "N", longitude: 100, ew: "E")
        #expect(c2.latitude == 10)
        #expect(c2.longitude == 100)
    }
    
    @Test("latitudeRadians and longitudeRadians compute values in radians")
    func radiansComputedCorrectly() async throws {
        let c = Coordinate(latitude: 180, longitude: 90)
        #expect(abs(c.latitudeRadians - Double.pi) < 0.00001)
        #expect(abs(c.longitudeRadians - Double.pi / 2) < 0.00001)
    }
    
    @Test("isValid returns true for valid values, false for invalid")
    func validityCheck() async throws {
        let valid = Coordinate(latitude: 45, longitude: 120)
        #expect(valid.isValid())
        let invalidLat = Coordinate(latitude: -91, longitude: 0)
        #expect(!invalidLat.isValid())
        let invalidLon = Coordinate(latitude: 0, longitude: 181)
        #expect(!invalidLon.isValid())
    }
}

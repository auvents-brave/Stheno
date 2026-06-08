import Testing

@testable import Stheno

@Suite("Coordinate Struct")
struct CoordinateTests {
  @Test func `Initializer stores latitude and longitude values correctly`() async throws {
    let c = Coordinate(latitude: 42.0, longitude: -71.0)
    #expect(c.latitude == 42.0)
    #expect(c.longitude == -71.0)
  }

  @Test func `Initializer with direction flips values appropriately`() async throws {
    let c = Coordinate(latitude: 23.5, ns: "S", longitude: 46.6, ew: "W")
    #expect(c.latitude == -23.5)
    #expect(c.longitude == -46.6)
    let c2 = Coordinate(latitude: 10, ns: "N", longitude: 100, ew: "E")
    #expect(c2.latitude == 10)
    #expect(c2.longitude == 100)
  }

  @Test func `latitudeRadians and longitudeRadians compute values in radians`() async throws {
    let c = Coordinate(latitude: 180, longitude: 90)
    #expect(abs(c.latitudeRadians - Double.pi) < 0.00001)
    #expect(abs(c.longitudeRadians - Double.pi / 2) < 0.00001)
  }

  @Test func `isValid returns true for valid values, false for invalid`() async throws {
    let valid = Coordinate(latitude: 45, longitude: 120)
    #expect(valid.isValid())
    let invalidLat = Coordinate(latitude: -91, longitude: 0)
    #expect(!invalidLat.isValid())
    let invalidLon = Coordinate(latitude: 0, longitude: 181)
    #expect(!invalidLon.isValid())
  }

  @Test func `formatted decimal degrees, both hemispheres`() {
    let north = Coordinate(latitude: 43.7384, longitude: 7.4246).formatted(as: .decimal())
    #expect(north.latitude == "43.74° N")
    #expect(north.longitude == "7.42° E")

    let south = Coordinate(latitude: -33.8700, longitude: -70.5000).formatted(as: .decimal())
    #expect(south.latitude == "33.87° S")
    #expect(south.longitude == "70.50° W")

    let precise = Coordinate(latitude: 0, longitude: 0).formatted(as: .decimal(decimals: 4))
    #expect(precise.latitude == "0.0000° N")
    #expect(precise.longitude == "0.0000° E")
  }

  @Test func `formatted degrees and decimal minutes`() {
    let f = Coordinate(latitude: 43.7390, longitude: 7.4246).formatted(as: .degreesMinutes())
    #expect(f.latitude == "43°44.3' N")
    #expect(f.longitude == "7°25.5' E")
  }

  @Test func `formatted degrees, minutes, seconds`() {
    let f = Coordinate(latitude: 43.7390, longitude: 7.4246).formatted(as: .degreesMinutesSeconds)
    #expect(f.latitude == "43°44'20\" N")
    #expect(f.longitude == "7°25'29\" E")
  }
}

@Suite("Formatted value/unit")
struct FormattedTests {
  @Test func `text joins value and unit, omits empty unit`() {
    #expect(Formatted("12", "kn").text == "12 kn")
    let cardinal = Formatted("NE")
    #expect(cardinal.unit == "")
    #expect(cardinal.text == "NE")
  }

  @Test func `formattedNumber: decimals, zero-padding, rounding, sign`() {
    #expect(formattedNumber(0, decimals: 0) == "0")
    #expect(formattedNumber(5, decimals: 2) == "5.00")
    #expect(formattedNumber(0.7, decimals: 3) == "0.700")
    #expect(formattedNumber(2.5, decimals: 0) == "3")
    #expect(formattedNumber(-3.14159, decimals: 2) == "-3.14")
    // A negative value that rounds to zero carries no sign.
    #expect(formattedNumber(-0.04, decimals: 1) == "0.0")
  }
}

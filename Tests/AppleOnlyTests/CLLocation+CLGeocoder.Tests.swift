import MapKit
import Testing
#if canImport(GeoToolbox)
    import GeoToolbox
#endif

@testable import AppleOnly

@Test("Geocoder", arguments: [
    ("Strait of Bonifacio natural reserve, Bonifacio, 20169", CLLocation(latitude: 41.470, longitude: 9.268), "Bonifacio"),
    ("Quai Louis II, Quai L'Hirondelle, 30, Monaco, MC, 98000", CLLocation(latitude: 43.736, longitude: 7.427), "Louis II"),
    ("Parco Nazionale dell\'Arcipelago di La Maddalena, La Maddalena, Sardinia", CLLocation(latitude: 41.192, longitude: 9.407), "Maddalena"),
    ("Apple Park, Apple Park Way, 1, Cupertino, CA, 95014", CLLocation(latitude: 37.335, longitude: -122.009), "Apple"),
])
func GeocoderTest(_ value: (String, CLLocation, String)) async throws {
    let placemark: CLPlacemark? = await value.1.reverseLocation()
    #expect(placemark?.description.contains(value.2) == true)

    let description: String = await value.1.reverseLocation()
    #expect(description.contains(value.2) == true)
}

#if canImport(GeoToolbox)
    @Test("new PlaceDescriptor test", arguments: [
        CLLocation(latitude: 41.470, longitude: 9.268),
        CLLocation(latitude: 43.736, longitude: 7.427),
        CLLocation(latitude: 41.192, longitude: 9.407),
        CLLocation(latitude: 37.335, longitude: -122.009),
        CLLocation(latitude: -33.857, longitude: 151.215),
    ])
    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    func dummy(_ value: CLLocation) async throws {
        let place = PlaceDescriptor(item: MKMapItem(location: value, address: nil))
        #expect(place?.commonName! == "Unknown Location")

        // Always returning Unknown Location. Probably due to a mandatory entitlement, I suppose.
    }
#endif

import MapKit
import SwiftUI

#if os(watchOS)
    /// A SwiftUI view that represents a map using MapKit.
    ///
    /// On watchOS, this view currently displays a placeholder text as map rendering is not supported.
    public struct MapKitView: View {
        /// Creates a basic MapKitView for watchOS.
        public init() {}

        /// Creates a MapKitView for watchOS with a single tile overlay cache directory and URL template.
        ///
        /// - Parameters:
        ///   - cacheDirectory: The directory to cache map tiles.
        ///   - urlTemplate: The URL template string for the tile overlay.
        public init(cacheDirectory: String, urlTemplate: String) {}

        /// Creates a MapKitView for watchOS with multiple tile overlay cache directories and URL templates.
        ///
        /// - Parameter overlays: An array of tuples where each contains a cache directory and URL template.
        public init(overlays: [(cacheDirectory: String, urlTemplate: String)]) {}

        /// The body of the view, displaying a placeholder text on watchOS.
        public var body: some View {
            Text("Not supported")
        }
    }
#else
    /// A SwiftUI view that wraps an MKMapView and supports multiple cached tile overlays.
    public struct MapKitView: View {
        /// The delegate handling MKMapView rendering and events.
        var delegate = MapDelegate()
        /// The underlying MKMapView instance displayed by this view.
        var map = MKMapView()

        /// Creates a MapKitView instance without any tile overlays.
        public init() {
            self.init(overlays: [])
        }

        /// Creates a MapKitView instance with a single tile overlay specified by cache directory and URL template.
        ///
        /// - Parameters:
        ///   - cacheDirectory: The directory to cache map tiles.
        ///   - urlTemplate: The URL template string for the tile overlay.
        public init(cacheDirectory: String, urlTemplate: String) {
            self.init(overlays: [(cacheDirectory: cacheDirectory, urlTemplate: urlTemplate)])
        }

        /// Creates a MapKitView instance with multiple tile overlays.
        ///
        /// - Parameter overlays: An array of tuples where each contains a cache directory and URL template.
        public init(overlays: [(cacheDirectory: String, urlTemplate: String)]) {
            map.delegate = delegate
            for overlay in overlays {
                map.addOverlay(CachedTileOverlay(directory: overlay.cacheDirectory, urlTemplate: overlay.urlTemplate))
            }
        }

        /// The SwiftUI view that wraps the MKMapView and ignores safe area edges.
        public var body: some View {
            WrapperView(view: map).edgesIgnoringSafeArea(.all)
                .accessibilityIdentifier("MapKitView.map")
        }
    }
#endif

/// Preview showing a plain MapKitView without any overlays.
#Preview("Plain") {
    MapKitView()
}

/// Preview showing a MapKitView with OpenStreetMap tile overlay.
#Preview("OpenStreetMap") {
    MapKitView(cacheDirectory: "openstreetmapcache", urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
}

/// Preview showing a MapKitView with OpenTopoMap tile overlay.
#Preview("OpenTopoMap") {
    MapKitView(cacheDirectory: "opentopomapcache", urlTemplate: "https://a.tile.opentopomap.org/{z}/{x}/{y}.png")
}

/// Preview showing a MapKitView with IGN (France) WMTS tile overlay.
/// See: https://geoservices.ign.fr/services-web-essentiels
#Preview("IGN (France)") {
    MapKitView(cacheDirectory: "igncache", urlTemplate: "https://data.geopf.fr/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y})")
}

/// Preview showing a MapKitView with Carte de Cassini (France XVIII) WMTS tile overlay.
#Preview("Carte de Cassini (France XVIII)") {
    MapKitView(cacheDirectory: "cassinicache", urlTemplate: "https://data.geopf.fr/wmts?layer=BNF-IGNF_GEOGRAPHICALGRIDSYSTEMS.CASSINI&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y})")
}

/// Preview showing a MapKitView with several overlays including OpenTopoMap and OpenSeaMap.
#Preview("Several overlays") {
    let overlays = [
        (cacheDirectory: "opentopomapcache", urlTemplate: "https://a.tile.opentopomap.org/{z}/{x}/{y}.png"),
        (cacheDirectory: "openseamapcache", urlTemplate: "https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png"),
    ]
    MapKitView(overlays: overlays)
}

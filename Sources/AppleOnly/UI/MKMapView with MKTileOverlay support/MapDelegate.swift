/// Handles MKMapView delegate responsibilities and tile overlay rendering across platforms.

#if !os(watchOS)
    import MapKit

    /// Type alias for delegate base class, differing by platform (UIResponder for iOS/tvOS, NSObject for macOS)
    #if os(macOS)
        typealias BaseMapDelegate = NSObject
    #else
        typealias BaseMapDelegate = UIResponder
    #endif

    /// MKMapViewDelegate implementation for rendering MKTileOverlay objects.
    /// Use this delegate to customize map overlay rendering in a cross-platform manner.
    class MapDelegate: BaseMapDelegate, MKMapViewDelegate {
        /// Provides a renderer for MKTileOverlay overlays. Asserts overlay is MKTileOverlay.
        /// - Parameters:
        ///   - mapView: The MKMapView requesting the renderer.
        ///   - overlay: The overlay to render. Must be an MKTileOverlay.
        /// - Returns: A renderer for MKTileOverlay overlays.
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            assert(overlay is MKTileOverlay)
            return MKTileOverlayRenderer(overlay: overlay)
        }
    }
#endif

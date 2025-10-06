///  WebKitView.swift
///
///  Provides a SwiftUI `View` wrapper around WKWebView for displaying web content in your UI.
///  On platforms where WebKit is unavailable (tvOS, watchOS), a fallback stub view is provided.
import SwiftUI

#if os(tvOS) || os(watchOS)
    /// A SwiftUI view that embeds a WKWebView for displaying web content.
    ///
    /// On tvOS and watchOS, this view displays a placeholder indicating lack of WebKit support.
    public struct WebKitView: View {
        let url: URL
        @State private var content: String = ""

        /// Creates a non-functional WebKitView for unsupported platforms.
        ///
        /// - Parameter url: The URL that would have been loaded, ignored on unsupported platforms.
        public init(url: URL) {
            self.url = url
        }

        /// The content and behavior of the view.
        public var body: some View {
            Text("Not supported")
        }
    }
#else
    import WebKit

    /// A SwiftUI view that embeds a WKWebView for displaying web content.
    ///
    /// On iOS, macOS, and compatible platforms, this view loads a URL or string into a WKWebView.
    public struct WebKitView: View {
        var web = WKWebView()

        /// Initializes a WebKitView to load the specified URL.
        ///
        /// - Parameter url: The URL to display in the embedded WKWebView.
        public init(url: URL) {
            web.load(URLRequest(url: url))
        }

        /// Initializes a WebKitView to load a given URL string.
        ///
        /// - Parameter string: A string convertible to a valid URL to load in the WKWebView.
        public init(string: String) {
            self.init(url: URL(string: string)!)
        }

        /// The content and behavior of the view.
        public var body: some View {
            WrapperView(view: web)
                .accessibilityIdentifier("WebKitView.webView")
        }
    }
#endif

#Preview {
    WebKitView(url: URL(string: "https://example.com")!)
}

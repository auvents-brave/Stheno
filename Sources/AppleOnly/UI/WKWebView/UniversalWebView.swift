/// UniversalWebView.swift
///
/// Provides a cross-platform SwiftUI view for displaying web content using either the latest SwiftUI WebView (for OS versions >= 26) or a fallback WebKitView for earlier versions.

import SwiftUI

#if os(tvOS) || os(watchOS)
    /// Typealias for tvOS and watchOS: always use WebKitView as the implementation.
    typealias UniversalWebView = WebKitView
#else
    import WebKit

    /// A SwiftUI view that displays web content, automatically choosing the best available implementation (WebView or WebKitView)
    /// based on the current OS version. Use this view to embed web pages in your SwiftUI app across all Apple platforms.
    public struct UniversalWebView: View {
        /// The underlying view implementation, using either SwiftUI's WebView (if available) or a fallback WebKitView.
        let webView: (any View)?

        /// Creates a new UniversalWebView with the specified URL.
        /// - Parameter url: The URL of the web page to load and display.
        public init(url: URL) {
            if #available(
                macOS 26,
                iOS 26,
                macCatalyst 26,
                visionOS 26,
                *
            ) {
                webView = WebView(url: url)
            } else {
                webView = WebKitView(url: url)
            }
        }

        /// Returns the rendered view (WebView or WebKitView), depending on OS version at runtime.
        public var body: some View {
            if #available(
                macOS 26,
                iOS 26,
                macCatalyst 26,
                visionOS 26,
                *
            ) {
                webView as! WebView
            } else {
                webView as! WebKitView
            }
        }
    }
#endif

#Preview {
    UniversalWebView(url: URL(string: "https://example.com")!)
}

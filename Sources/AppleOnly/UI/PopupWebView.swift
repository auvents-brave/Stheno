/// PopupWebView.swift
///
/// Contains `PopupWebView`, a SwiftUI view for presenting a web page in a popover, with platform-specific handling for tvOS and watchOS.

import SwiftUI
#if canImport(WebKit)
    import WebKit
#endif

/// A SwiftUI view that displays a web page in a popover, with platform-specific presentations.
///
/// On iOS, macOS, and similar platforms, provides a button that opens a web view in a popover.
/// On tvOS, shows the link as text. On watchOS, simply uses a `Link`.
struct PopupWebView: View {
    /// Environment value to open URLs in the system browser.
    @Environment(\.openURL) private var openURL
    /// Tracks whether the popover with the web view is shown.
    @State private var showingPopover = false
    /// The URL to present.
    var url: URL
    /// Optional title displayed alongside the link.
    var title: String?

    /// The body of the PopupWebView, which adapts its UI based on the platform.
    var body: some View {
        #if os(tvOS)
            Text(title != nil ? title! + " (" + url.absoluteString + ")" : url.absoluteString)
        #elseif os(watchOS)
            Link(title ?? url.absoluteString, destination: url)
        #else
            HStack {
                if title != nil {
                    Text(title!)
                }
                Button(action: { showingPopover = true }) {
                    Image(systemName: "link")
                }
                .popover(isPresented: $showingPopover) {
                    VStack {
                        Button("Open in browser", systemImage: "safari", action: { openURL(url) })
                            .offset(y: 2)
                            .frame(alignment: .leading)
                        UniversalWebView(url: url)
                            .frame(idealWidth: 400, idealHeight: 500)
                    }
                }
            }
        #endif
    }
}

#Preview("No title") {
    PopupWebView(url: URL(string: "https://example.com")!)
}

#Preview("With title") {
    PopupWebView(url: URL(string: "https://example.com")!, title: "Example")
}

#Preview("In List") {
    List {
		PopupWebView(url: URL(string: "https://apple.com")!, title: "Apple")
        PopupWebView(url: URL(string: "https://example.com")!, title: "Example")
    }
}

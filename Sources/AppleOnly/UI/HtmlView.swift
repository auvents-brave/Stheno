import Logging
import SwiftUI

@available(iOS 15, *)
struct HtmlView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric private var bodySize = 17.0
    let forHTML: String

    var body: some View {
        let fontColor = (colorScheme == .dark) ? "white" : "black"
        let cleaned = forHTML.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        if cleaned == forHTML {
            Text(forHTML)
        } else {
            let fullHTML = """
            <!doctype html>
            <html>
              <head>
            	<style>
            	  body {
            		font-family: "-apple-system";
            		font-size: \(Int(bodySize))px;
            		color:\(fontColor)
            	  }
            	</style>
              </head>
              <body>
            	\(forHTML)
              </body>
            </html>
            """
            if let nsAttributedString = try? NSAttributedString(
                data: Data(fullHTML.utf8),
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
            ) {
                Text(AttributedString(nsAttributedString))
            } else {
                Text("") // still returns a View
                    .onAppear {
                        Logger(label: "HtmlView")
                            .error("NSAttributedString failed", metadata: ["html": "\(forHTML)"])
                    }
            }
        }
    }
}

@available(iOS 15, *)
#Preview {
    VStack {
        HtmlView(forHTML: "not html text")
        HtmlView(forHTML: "Hello <World>!") // recognised as html tagged
        HtmlView(forHTML: "0 < 8 < 17")
        HtmlView(forHTML: "0 < 8 > 3") // recognised as html tagged

        HtmlView(forHTML: "Hello <B>World</B>")
        Divider()
        HtmlView(
            forHTML: "<p style=\"font-family:Georgia, Times, serif;\">Serif font.</p>"
        )
        Divider()
        HtmlView(
            forHTML: "<p style=\"color:#B22222\">Color text and <span style=\"color:limegreen;\">another color</span>, and now back to the same. Oh, and here's a <span style=\"background-color:PaleGreen;\">different background color</span> just in case you need it!</p>"
        )
        Divider()
        HtmlView(forHTML: "<tt>Teletype text.</tt>")
    }
    .background(Color(.lightGray))
}

import SwiftUI

@available(iOS 15, *)
@ViewBuilder func HtmlView(_ value: String) -> some View {
    @Environment(\.colorScheme) var colorScheme

    let fontColor = (colorScheme == .dark) ? "white" : "black"

    let cleaned = value.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

    @ScaledMetric var bodySize = 17.0

    // color: \(getRgbInfo(of: .secondary));

    if cleaned == value {
        Text(value)
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
                                                       \(colorScheme)  \(fontColor) 
              \(value)
            </body>
          </html>
        """

        if let nsAttributedString = try? NSAttributedString(data: Data(fullHTML.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            Text(AttributedString(nsAttributedString))
        } else {
            Text("NSAttributedString failed ") + Text(cleaned)
        }
    }
}

@available(iOS 15, *)
#Preview {
    VStack {
        HtmlView("not html text")
        HtmlView("Hello <World>!") // recognised as html tagged
        HtmlView("0 < 8 < 17")
        HtmlView("0 < 8 > 3") // recognised as html tagged

        HtmlView("Hello <B>World</B>")
        Divider()
        HtmlView(
            "<p style=\"font-family:Georgia, Times, serif;\">Serif font.</p>"
        )
        Divider()
        HtmlView(
            "<p style=\"color:#B22222\">Color text and <span style=\"color:limegreen;\">another color</span>, and now back to the same. Oh, and here's a <span style=\"background-color:PaleGreen;\">different background color</span> just in case you need it!</p>"
        )
        Divider()
        HtmlView("<tt>Teletype text.</tt>")
    }
    .background(Color(.lightGray))
}

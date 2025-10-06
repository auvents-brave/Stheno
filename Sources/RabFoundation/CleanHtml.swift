import Foundation

/**
 Removes all known HTML tags from a string and decodes common HTML entities to their Unicode equivalents.

 This function is intended to sanitize and clean up raw HTML content by:
  - Removing an extensive list of known HTML tags (including inline, block, form, and media tags),
  - Decoding a wide range of HTML entities (such as &amp;, &lt;, &gt;, &copy;, &euro;, and many more) into displayable characters.

 - Parameter text: The input string containing HTML content to be sanitized. This can be either a raw HTML source or a text fragment with embedded HTML.
 - Returns: A plain, human-readable string with all recognized HTML tags removed and all supported HTML entities decoded. If the input contains only safe, non-HTML content, the original string is returned.

 ## Example
 ```swift
    let html = "<p>Copyright &copy; 2025</p>"
    let plain = CleanHTML(from: html)
    // plain == "Copyright © 2025"
 ```
 */
public func CleanHTML(from text: String) -> String {
    // Exhaustive list of known HTML tags (can be expanded as needed)
    let htmlTags = [
        // Core and block tags
        "html", "head", "body", "div", "span", "p", "a", "img", "br", "hr", "h1", "h2", "h3", "h4", "h5", "h6",
        "ul", "ol", "li", "table", "tr", "td", "th", "form", "input", "button", "script", "style", "link", "meta",
        "title", "footer", "header", "nav", "section", "article", "aside", "main",
        // Inline and formatting
        "b", "strong", "em", "i", "u", "mark", "small", "del", "ins", "sub", "sup", "code", "pre", "s", "abbr", "cite",
        "dfn", "kbd", "samp", "var", "q", "blockquote", "address", "time", "progress", "meter", "wbr", "details",
        // Media
        "audio", "video", "source", "track", "canvas", "map", "area", "svg", "iframe", "object", "embed", "param",
        "picture", "figcaption", "figure",
        // Form elements
        "select", "option", "textarea", "label", "fieldset", "legend", "datalist", "optgroup", "output",
        // Misc
        "noscript", "template", "summary", "dialog", "menu", "menuitem", "data", "col", "colgroup",
    ]

    // Compose regex for tags, case-insensitive
    let tagPattern = "<\\s*\\/?\\s*(" + htmlTags.joined(separator: "|") + ")(\\s+[^>]*)?>"
    guard let regex = try? NSRegularExpression(pattern: tagPattern, options: [.caseInsensitive]) else {
        return text // If regex fails, return the original
    }
    let range = NSRange(text.startIndex ..< text.endIndex, in: text)
    let tagStripped = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")

    // Decode expanded set of HTML entities
    return decodeHTMLEntities(in: tagStripped)
}

internal func isHTML(_ text: String) -> Bool {
    return text != CleanHTML(from: text)
}

/// Decodes an expanded set of HTML entities (&amp;, &lt;, &gt;, &quot;, &apos;, &nbsp;, &copy;, &reg;, &euro;, etc.).
private func decodeHTMLEntities(in text: String) -> String {
    var result = text
    let entities: [String: String] = [
        // Basic entities
        "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": "\"", "&apos;": "'", "&nbsp;": " ",
        // Currency
        "&euro;": "€", "&yen;": "¥", "&pound;": "£", "&cent;": "¢",
        // Quotes
        "&ldquo;": "“", "&rdquo;": "”", "&lsquo;": "‘", "&rsquo;": "’", "&laquo;": "«", "&raquo;": "»",
        // Math/symbols
        "&deg;": "°", "&plusmn;": "±", "&copy;": "©", "&reg;": "®",
        // Latin-1 Supplement (European letters)
        "&Agrave;": "À", "&Aacute;": "Á", "&Acirc;": "Â", "&Atilde;": "Ã", "&Auml;": "Ä", "&Aring;": "Å",
        "&AElig;": "Æ", "&Ccedil;": "Ç", "&Egrave;": "È", "&Eacute;": "É", "&Ecirc;": "Ê", "&Euml;": "Ë",
        "&Igrave;": "Ì", "&Iacute;": "Í", "&Icirc;": "Î", "&Iuml;": "Ï", "&ETH;": "Ð", "&Ntilde;": "Ñ",
        "&Ograve;": "Ò", "&Oacute;": "Ó", "&Ocirc;": "Ô", "&Otilde;": "Õ", "&Ouml;": "Ö", "&Oslash;": "Ø",
        "&Ugrave;": "Ù", "&Uacute;": "Ú", "&Ucirc;": "Û", "&Uuml;": "Ü", "&Yacute;": "Ý", "&Thorn;": "Þ",
        "&szlig;": "ß", "&agrave;": "à", "&aacute;": "á", "&acirc;": "â", "&atilde;": "ã", "&auml;": "ä",
        "&aring;": "å", "&aelig;": "æ", "&ccedil;": "ç", "&egrave;": "è", "&eacute;": "é", "&ecirc;": "ê",
        "&euml;": "ë", "&igrave;": "ì", "&iacute;": "í", "&icirc;": "î", "&iuml;": "ï", "&eth;": "ð",
        "&ntilde;": "ñ", "&ograve;": "ò", "&oacute;": "ó", "&ocirc;": "ô", "&otilde;": "õ", "&ouml;": "ö",
        "&oslash;": "ø", "&ugrave;": "ù", "&uacute;": "ú", "&ucirc;": "û", "&uuml;": "ü", "&yacute;": "ý",
        "&thorn;": "þ",
        // Central/Eastern European
        "&Sacute;": "Ś", "&sacute;": "ś", "&Zacute;": "Ź", "&zacute;": "ź", "&Scaron;": "Š", "&scaron;": "š",
        "&Zcaron;": "Ž", "&zcaron;": "ž", "&Ccaron;": "Č", "&ccaron;": "č", "&Ecaron;": "Ě", "&ecaron;": "ě",
        "&Dcaron;": "Ď", "&dcaron;": "ď", "&Ncaron;": "Ň", "&ncaron;": "ň", "&Rcaron;": "Ř", "&rcaron;": "ř",
        "&Tcaron;": "Ť", "&tcaron;": "ť", "&Uring;": "Ů", "&uring;": "ů", "&Lacute;": "Ĺ", "&lacute;": "ĺ",
        "&Lcaron;": "Ľ", "&lcaron;": "ľ",
        // Misc
        "&OElig;": "Œ", "&oelig;": "œ", "&yuml;": "ÿ", "&Yuml;": "Ÿ",
    ]
    for (entity, character) in entities {
        result = result.replacingOccurrences(of: entity, with: character)
    }
    return result
}

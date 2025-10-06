import Foundation
import Logging

extension Date {
    enum DisplayAs {
        case asUniversalTime
        case asLocalTime
    }

    /// Initializes a `Date` from an ISO 8601 formatted string, accepting optional fractional seconds.
    /// Logs an error if the string cannot be parsed.
    init(fromISO: String) {
        self.init()

        // Default ISO8601DateFormatter does not support fractional seconds
        // .withFractionalSeconds expects fractional seconds onbly and will fail if not.
        // Given 45.321 seconds, the nano component for the returned Date will be 320999145, not 321
        // → May it be usefull to round it?
        let formatter = ISO8601DateFormatter()
        if fromISO.contains(".") {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        }
        guard let date = formatter.date(from: fromISO) else {
            Logger(label: "").error("Something went wrong", metadata: ["fromISO": "\(fromISO)"])
            return
        }
        self = date
    }

    /// Returns a formatted date string using the provided formatter.
    /// Adjusts the formatter's time zone based on the `display` mode.
    /// - Parameters:
    ///   - display: Specifies whether to display as universal or local time.
    ///   - formatter: The `DateFormatter` to use for formatting.
    /// - Returns: The formatted date string.
    func Display(display: DisplayAs, formatter: DateFormatter) -> String {
        formatter.timeZone = if display == .asUniversalTime {
            TimeZone(abbreviation: "UTC")
        } else {
            TimeZone.current
        }
        return formatter.string(from: self)
    }

    /// Returns a formatted date string using a default medium style date and time formatter.
    /// Adjusts the time zone based on the `display` mode.
    /// - Parameter display: Specifies whether to display as universal or local time.
    /// - Returns: The formatted date string.
    func Display(display: DisplayAs) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return Display(display: display, formatter: formatter)
    }
}

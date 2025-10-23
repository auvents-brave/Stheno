import Foundation
import Logging

/// Date utilities for parsing ISO 8601 strings and formatting for different time zones.
/// - Note: Uses `ISO8601DateFormatter` and `DateFormatter`.
extension Date {
    enum DisplayAs: Equatable {
        case asUniversalTime
        case asDeviceTime
        case asLocalTime(TimeZone)
    }

    /// Initializes a `Date` from an ISO 8601 formatted string, accepting optional fractional seconds.
    /// - Parameter fromISO: The ISO 8601 string representation of the date, which may include fractional seconds (e.g., "2023-10-23T15:00:45.321Z") or not (e.g., "2023-10-23T15:00:45Z").
    /// - Important: Fractional seconds are parsed with sub-millisecond precision using `ISO8601DateFormatter`.
    init(fromISO: String) {
        self.init()
        let formatter = ISO8601DateFormatter()
        if fromISO.contains(".") {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        }
        guard let date = formatter.date(from: fromISO) else {
            Logger(label: "Date+UTC").error("Failed to parse ISO 8601 date string.", metadata: ["fromISO": "\(fromISO)"])
            return
        }
        self = date
    }

    /// Returns a formatted string for the date using the provided formatter.
    /// Adjusts the formatter's time zone based on the `display` mode.
    /// - Parameters:
    ///   - display: Specifies whether to display as universal, device, or local time.
    ///   - formatter: The `DateFormatter` to use for formatting.
    /// - Returns: A formatted date string.
    func Display(display: DisplayAs, formatter: DateFormatter) -> String {
        formatter.timeZone = switch display {
        case .asUniversalTime:
            TimeZone(abbreviation: "UTC")
        case .asDeviceTime:
            TimeZone.current
        case let .asLocalTime(timeZone):
            timeZone
        }
        return formatter.string(from: self)
    }

    /// Returns a formatted date string using a default medium style date and time formatter.
    /// Adjusts the time zone based on the `display` mode.
    /// - Parameter display: Specifies whether to display as universal, device, or local time.
    /// - Returns: The formatted date string.
    /// - SeeAlso: `Display(display:formatter:)`
    func Display(display: DisplayAs) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return Display(display: display, formatter: formatter)
    }
}

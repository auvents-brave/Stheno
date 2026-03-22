import Foundation

/// Defines how a date should be displayed.
public enum DateTimeType: String {
    case utc = " UT"
    case local = " LT"
}

/// Represents a date with helpers for parsing and formatting.
public struct DateTime {
    public let date: Date

    /// Creates a date-time with the provided date.
    public init(date: Date) {
        self.date = date
    }

    public static var relativeAvailable: Bool {
        #if canImport(Darwin)
            // RelativeDateTimeFormatter is available on Apple platforms via Foundation
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                return true
            }
        #endif
        return false
    }

    /// Initializes from an ISO 8601 string, accepting fractional seconds and time zone indicators.
    public init?(iso8601String: String) {
        // Normalize comma to dot for fractional seconds.
        let normalized = iso8601String.replacingOccurrences(of: ",", with: ".")

        // 1) Try ISO8601DateFormatter (with fractional seconds).
        let isoWithFraction = ISO8601DateFormatter()
        isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        // Use UTC as default when the input string does not include a timezone.
        isoWithFraction.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = isoWithFraction.date(from: normalized) {
            self.date = date
            return
        }

        // 2) Try ISO8601DateFormatter (without fractional seconds).
        let isoNoFraction = ISO8601DateFormatter()
        isoNoFraction.formatOptions = [.withInternetDateTime]
        isoNoFraction.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = isoNoFraction.date(from: normalized) {
            self.date = date
            return
        }

        // 3) Fallback to DateFormatter to support up to 9 fractional digits.
        let posix = Locale(identifier: "en_US_POSIX")
        let df = DateFormatter()
        df.locale = posix

        let patternsWithTimeZone = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSXXXXX", // up to 9 fractional digits
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // 6 fractional digits
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX", // 3 fractional digits
            "yyyy-MM-dd'T'HH:mm:ssXXXXX", // no fractional seconds
        ]
        df.timeZone = TimeZone(secondsFromGMT: 0)
        for pattern in patternsWithTimeZone {
            df.dateFormat = pattern
            if let date = df.date(from: normalized) {
                self.date = date
                return
            }
        }

        let patternsWithoutTimeZone = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS", // up to 9 fractional digits
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", // 6 fractional digits
            "yyyy-MM-dd'T'HH:mm:ss.SSS", // 3 fractional digits
            "yyyy-MM-dd'T'HH:mm:ss", // no fractional seconds
        ]
        df.timeZone = TimeZone.current
        for pattern in patternsWithoutTimeZone {
            df.dateFormat = pattern
            if let date = df.date(from: normalized) {
                self.date = date
                return
            }
        }

        return nil
    }

    /// Formats the date using the given format string and display type.
    public func formatted(in targetType: DateTimeType, format: String = "yyyy-MM-dd HH:mm:ss") -> (date: String, time: String, unit: String) {
        let formatParts = format.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
        let dateFormat = formatParts.first.map(String.init) ?? ""
        let timeFormat = formatParts.count > 1 ? String(formatParts[1]) : ""

        func formattedComponents(using formatter: DateFormatter) -> (date: String, time: String) {
            let dateString: String
            if dateFormat.isEmpty {
                dateString = ""
            } else {
                formatter.dateFormat = dateFormat
                dateString = formatter.string(from: date)
            }

            let timeString: String
            if timeFormat.isEmpty {
                timeString = ""
            } else {
                formatter.dateFormat = timeFormat
                timeString = formatter.string(from: date)
            }

            return (dateString, timeString)
        }

        let formatter = DateFormatter()
        switch targetType {
        case .utc:
            formatter.timeZone = TimeZone(abbreviation: "UTC")
        case .local:
            formatter.timeZone = TimeZone.current
        }
        let components = formattedComponents(using: formatter)
        return (components.date, components.time, targetType.rawValue)
    }

    /// Formats to a relative string when available.
    public func formattedRelative() -> String {
        #if canImport(Darwin)
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                let rel = RelativeDateTimeFormatter()
                rel.unitsStyle = .full
                return (rel.localizedString(for: self.date, relativeTo: Date()))
            }
        #endif
        return ""
    }

    /// Formats the date using ISO 8601 with optional fractional seconds.
    public func formattedISO(in targetType: DateTimeType) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        switch targetType {
        case .utc:
            formatter.timeZone = TimeZone(abbreviation: "UTC")
        case .local:
            formatter.timeZone = TimeZone.current
        }

        return formatter.string(from: date)
    }
}

// MARK: - Examples (Playground)

#if canImport(Playgrounds) && !NO_PLAYGROUND_EXAMPLES
    import Playgrounds

    #Playground {
        let dateTime = DateTime(date: Date().addingTimeInterval(-5 * 60))

        _ = dateTime.formatted(in: .utc)
        _ = dateTime.formattedISO(in: .utc)

        _ = dateTime.formatted(in: .local)
        _ = dateTime.formattedISO(in: .local)

        _ = dateTime.formattedRelative()

        // 2) Parse ISO with local offset and with Z, then format in local and UTC
        let inputs = [
            "2026-01-30",
            "20260130",
            "2026-01-30T14:05",
            "2026-01-30T14:05:09",
            "2026-01-30T14:05:09.4",
            "2026-01-30T14:05:09.47",
            "2026-01-30T14:05:09.472",
            "2026-01-30T13:05Z",
            "2026-01-30T13:05:09Z",
            "2026-01-30T13:05:09.4Z",
            "2026-01-30T13:05:09.472Z",
            "2026-01-30T13:05:09.472839Z",
            "2026-01-30T14:05+01:00",
            "2026-01-30T14:05:09+01:00",
            "2026-01-30T14:05:09.47+01:00",
            "2026-01-30T14:05:09.472839+01:00",
            "2026-01-30T08:05:09-05:00",
            "2026",
            "2026-01",
            "2026-01-30T14",
            "20260130T140509Z",
            "20260130T140509.472Z",
            "2026-01-30T14:05:09,4",
            "2026-01-30T14:05:09,47",
            "2026-01-30T13:05:09,472Z",
            "2026-01-30T14:05:09,472+01:00",

            "2026-01-30T13:05:09.930",
            "2026-01-30T13:05:09.930+01:00",
            "2026-01-30T13:05:09Z",
            "2026-01-30T13:05:09.9Z",
            "2026-01-30T13:05:09.93Z",
            "2026-01-30T13:05:09.930Z",
            "2026-01-30T13:05:09.9305204390753183206049Z",
        ]

        for input in inputs {
            _ = input + " - " + DateTime(iso8601String: input).debugDescription
        }
    }
#endif

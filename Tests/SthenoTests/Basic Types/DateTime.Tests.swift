import Foundation
import Testing

@testable import Stheno

#if canImport(Darwin)
@Suite("DateTime Tests")
struct DateTimeTests {
    @Test("DateTime preserves original date")
    func preservesOriginal() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date)
        #expect(dateTime.date == date)
    }

    @Test("DateTime initialization from ISO8601 string (Z)")
    func initFromISO8601UTC() {
        let dateTime = DateTime(iso8601String: "2024-01-23T15:30:00Z")
        #expect(dateTime != nil)
    }

    @Test("DateTime initialization from ISO8601 string (offset)")
    func initFromISO8601Local() {
        let dateTime = DateTime(iso8601String: "2024-01-23T15:30:00+01:00")
        #expect(dateTime != nil)
    }

    @Test("DateTime initialization from invalid ISO8601 string returns nil")
    func initFromInvalidISO8601() {
        let dateTime = DateTime(iso8601String: "invalid-date")
        #expect(dateTime == nil)
    }

    @Test("DateTime formatted output contains date, time, and unit")
    func formattedOutput() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date)
        let formatted = dateTime.formatted(in: .utc)
        #expect(formatted.date == "2024-01-01")
        #expect(formatted.time == "00:00:00")
        #expect(formatted.unit == " UT")
    }

    @Test("DateTime ISO formatted output UTC")
    func isoFormattedOutputUTC() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date)
        let isoFormatted = dateTime.formattedISO(in: .utc)
        #expect(isoFormatted.contains("2024-01-01"))
        #expect(isoFormatted.contains("T"))
    }

    @Test("DateTime custom format")
    func customFormat() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date)
        let formatted = dateTime.formatted(in: .utc, format: "dd/MM/yyyy")
        #expect(formatted.date == "01/01/2024")
        #expect(formatted.time.isEmpty)
    }

    @Test("DateTime accepts comma fractional seconds")
    func acceptsCommaFractionalSeconds() {
        let dateTime = DateTime(iso8601String: "2026-01-30T13:05:09,472Z")
        #expect(dateTime != nil)
    }

    @Test("Round-trip ISO8601 parsing")
    func roundTripISO8601() {
        let originalDate = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: originalDate)
        let isoString = dateTime.formattedISO(in: .utc)

        let parsedDateTime = DateTime(iso8601String: isoString)
        #expect(parsedDateTime != nil)
        #expect(abs(parsedDateTime!.date.timeIntervalSince(originalDate)) < 1.0)
    }
}
#endif

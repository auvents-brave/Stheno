import Foundation
import Testing

@testable import Stheno

@Suite("DateTime Tests")
struct DateTimeTests {
    @Test func `DateTime preserves original date`() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date)
        #expect(dateTime.date == date)
    }

    @Test func `DateTime initialization from ISO8601 string (Z)`() {
        let dateTime = DateTime(iso8601String: "2024-01-23T15:30:00Z")
        #expect(dateTime != nil)
    }

    @Test func `DateTime initialization from ISO8601 string (offset)`() {
        let dateTime = DateTime(iso8601String: "2024-01-23T15:30:00+01:00")
        #expect(dateTime != nil)
    }

    @Test func `DateTime initialization from invalid ISO8601 string returns nil`() {
        let dateTime = DateTime(iso8601String: "invalid-date")
        #expect(dateTime == nil)
    }

    @Test func `DateTime formatted output contains date, time, and unit`() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date)
        let formatted = dateTime.formatted(in: .utc)
        #expect(formatted.date == "2024-01-01")
        #expect(formatted.time == "00:00:00")
        #expect(formatted.unit == " UT")
    }

    @Test func `DateTime ISO formatted output UTC`() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date)
        let isoFormatted = dateTime.formattedISO(in: .utc)
        #expect(isoFormatted.contains("2024-01-01"))
        #expect(isoFormatted.contains("T"))
    }

    @Test func `DateTime custom format`() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: date)
        let formatted = dateTime.formatted(in: .utc, format: "dd/MM/yyyy")
        #expect(formatted.date == "01/01/2024")
        #expect(formatted.time.isEmpty)
    }

    @Test func `DateTime accepts comma fractional seconds`() {
        let dateTime = DateTime(iso8601String: "2026-01-30T13:05:09,472Z")
        #expect(dateTime != nil)
    }

    @Test func `Round-trip ISO8601 parsing`() {
        let originalDate = Date(timeIntervalSince1970: 1704067200)
        let dateTime = DateTime(date: originalDate)
        let isoString = dateTime.formattedISO(in: .utc)

        let parsedDateTime = DateTime(iso8601String: isoString)
        #expect(parsedDateTime != nil)
        #expect(abs(parsedDateTime!.date.timeIntervalSince(originalDate)) < 1.0)
    }
}

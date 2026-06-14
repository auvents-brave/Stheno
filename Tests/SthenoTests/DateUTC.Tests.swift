import Foundation
import Testing

@testable import Stheno

@Suite("Date+UTC")
struct DateUTCTests {

	/// 2023-10-23T15:00:45 UTC, built independently of the parser under test.
	private var reference: Date {
		var components = DateComponents()
		components.year = 2023
		components.month = 10
		components.day = 23
		components.hour = 15
		components.minute = 0
		components.second = 45
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(identifier: "UTC")!
		return calendar.date(from: components)!
	}

	@Test func `Parses an ISO 8601 string without fractional seconds`() {
		let parsed = Date(fromISO: "2023-10-23T15:00:45Z")
		#expect(abs(parsed.timeIntervalSince(reference)) < 0.001)
	}

	@Test func `Parses an ISO 8601 string with fractional seconds`() {
		let parsed = Date(fromISO: "2023-10-23T15:00:45.500Z")
		#expect(abs(parsed.timeIntervalSince(reference) - 0.5) < 0.01)
	}

	@Test func `An unparseable string falls back to the current date`() {
		// The failure path logs and returns the default-initialised date (≈ now),
		// rather than crashing.
		let parsed = Date(fromISO: "not-a-date")
		#expect(abs(parsed.timeIntervalSinceNow) < 5)
	}

	@Test func `Displays universal and local time with an explicit formatter`() {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		#expect(reference.display(displayAs: .asUniversalTime, formatter: formatter) == "2023-10-23 15:00:45")
		// 23 Oct 2023 is still CEST (UTC+2; DST ended 29 Oct), so 15:00Z → 17:00.
		let paris = TimeZone(identifier: "Europe/Paris")!
		#expect(reference.display(displayAs: .asLocalTime(paris), formatter: formatter) == "2023-10-23 17:00:45")
	}

	@Test func `Device-time display and the default formatter produce a non-empty string`() {
		// The device time zone varies by runner, so assert only that each mode
		// renders something — this exercises the default-formatter convenience.
		#expect(!reference.display(displayAs: .asDeviceTime).isEmpty)
		#expect(!reference.display(displayAs: .asUniversalTime).isEmpty)
		#expect(!reference.display(displayAs: .asLocalTime(.current)).isEmpty)
	}
}

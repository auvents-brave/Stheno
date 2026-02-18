import Foundation
import Testing

@testable import Stheno

// Date formatting defaults are locale-/platform-dependent.
// Accept both 24-hour and AM/PM variants for default Display() output.
@Test func `Create Date from ISO string`() async throws {
  let d = Date(fromISO: "2025-08-26T09:29:23.321Z")
	let londonTimeZone = TimeZone(identifier: "Europe/London")!

  let universal = d.Display(display: .asUniversalTime)
  let london = d.Display(display: .asLocalTime(londonTimeZone))

  let universalExpected: Set<String> = [
    "26/08/2025, 09:29",
    "26/08/2025 09:29",
    "26/08/2025, 9:29 AM",
    "26/08/2025, 9:29\u{202F}AM"
  ]

  let londonExpected: Set<String> = [
    "26/08/2025, 10:29",
    "26/08/2025 10:29",
    "26/08/2025, 10:29 AM",
    "26/08/2025, 10:29\u{202F}AM"
  ]

  #expect(universalExpected.contains(universal))
  #expect(londonExpected.contains(london))

  let formatter = DateFormatter()
  formatter.dateFormat = "dd/MM/yy '-' HH:mm"
  #expect("26/08/25 - 09:29" == d.Display(display: .asUniversalTime, formatter: formatter))
#if canImport(Darwin)
  #expect("26/08/25 - 10:29" == d.Display(display: .asLocalTime(londonTimeZone), formatter: formatter))
#else
  #expect("26/08/25 - 10:29" == d.Display(display: .asLocalTime(londonTimeZone), formatter: formatter))
#endif

    let withoutNano = Calendar.current.date(from: DateComponents(
        timeZone: TimeZone(abbreviation: "GMT"),
        year: 2025,
        month: 8,
        day: 26,
        hour: 10,
        minute: 29,
        second: 23))

    let withNano = Calendar.current.date(from: DateComponents(
        timeZone: TimeZone(abbreviation: "GMT"),
        year: 2025,
        month: 8,
        day: 26,
        hour: 10,
        minute: 29,
        second: 23,
        nanosecond: 321000000))

    let nano = Calendar.current.component(.nanosecond, from: d)
    #expect(round(Double(nano) / 1000000.0) == 321)

    #expect(round(Double(nano) / 1000000.0) == round(Double(Calendar.current.component(.nanosecond, from: withNano!)) / 1000000.0))

    #expect(withoutNano == ISO8601DateFormatter().date(from: "2025-08-26T12:29:23+02:00"))
    #expect(withoutNano == ISO8601DateFormatter().date(from: "2025-08-26T10:29:23Z"))
}

import Foundation
import Testing

@testable import Stheno

// DateFormatter() is locale-dependent and platform-dependent. For some locales (like "en_GB"), the default time format on Darwin is 18:00 but Linux's Foundation implementation or ICU data includes the AM/PM (6:00 PM).
@Test func `Create Date from ISO string`() async throws {
  let d = Date(fromISO: "2025-08-26T09:29:23.321Z")

#if Xcode
  #expect(["en_GB", "en_001"].contains(DateFormatter().locale.identifier))
#endif

#if canImport(Darwin)
#if Xcode
	#expect("26/08/2025, 09:29" == d.Display(display: .asUniversalTime))
	#expect(
		"26/08/2025, 10:29" == d
			.Display(
				display: .asLocalTime(TimeZone(identifier: "Europe/London")!)
			)
	)
  #else
	#expect("26/08/2025 09:29" == d.Display(display: .asUniversalTime))
	#expect("26/08/2025 10:29" == d.Display(display: .asLocalTime(TimeZone(identifier: "Europe/London"))!))
#endif
#else
	#expect("26/08/2025, 9:29 AM" == d.Display(display: .asUniversalTime))
	#expect("26/08/2025, 10:29 AM" == d.Display(display: .asLocalTime(TimeZone(identifier: "Europe/London")!)))
  #endif

  let formatter = DateFormatter()
  formatter.dateFormat = "dd/MM/yy '-' HH:mm"
  #expect("26/08/25 - 09:29" == d.Display(display: .asUniversalTime, formatter: formatter))
  #if canImport(Darwin)
  #expect("26/08/25 - 10:29" == d.Display(display: .asLocalTime(TimeZone(identifier: "Europe/London")!), formatter: formatter))
  #else
  #expect("26/08/25 - 10:29" == d.Display(display: .asLocalTime(TimeZone(identifier: "Europe/London")!), formatter: formatter))
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

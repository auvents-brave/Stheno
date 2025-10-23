import Foundation
import Testing

@testable import Stheno

// DateFormatter() is locale-dependent and platform-dependent. For some locales (like "en_GB"), the default time format on Darwin is 18:00 but Linux's Foundation implementation or ICU data includes the AM/PM (6:00 PM).
private func stripTrailingAM(_ s: String) -> String {
    s.hasSuffix(" AM") ? String(s.dropLast(3)) : s
}

@Test func `Create Date from ISO string`() async throws {
  let d = Date(fromISO: "2025-08-26T09:29:23.321Z")

#if Xcode
  #expect(["en_GB", "en_001"].contains(DateFormatter().locale.identifier))
#endif

#if VSCode
	ezfezfezf
#endif

  #expect("09:29" == stripTrailingAM("09:29 AM"))

#if Xcode
	#expect("26/08/2025, 09:29" == stripTrailingAM(d.Display(display: .asUniversalTime)), "a")
	#expect("26/08/2025, 10:29" == stripTrailingAM(d.Display(display: .asLocalTime)), "b")
	#else
	#expect("26/08/2025 09:29" == stripTrailingAM(d.Display(display: .asUniversalTime)), "a")
	#expect("26/08/2025 10:29" == stripTrailingAM(d.Display(display: .asLocalTime)), "b")
	#endif

  let formatter = DateFormatter()
  #if !XCODE
  formatter.locale = Locale(identifier: "en_GB")
#endif
  formatter.dateFormat = "dd/MM/yy '-' HH:mm"
  #expect("26/08/25 - 09:29" == stripTrailingAM(d.Display(display: .asUniversalTime, formatter: formatter)), "c")
	#expect("26/08/25 - 10:29" == stripTrailingAM(d.Display(display: .asLocalTime, formatter: formatter)), "d")

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

    #expect(withoutNano == ISO8601DateFormatter().date(from: "2025-08-26T12:29:23+02:00"), "e")
    #expect(withoutNano == ISO8601DateFormatter().date(from: "2025-08-26T10:29:23Z"), "f")
}

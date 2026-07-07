// The C ABI non-Swift hosts load. Rules of the surface: every function is
// `@_cdecl`, takes and returns C types only, and every returned string is a
// caller-owned UTF-8 buffer to release with `stheno_bridge_string_free`.

internal import Foundation
internal import Stheno

/// Copies a Swift string into a caller-owned, NUL-terminated C buffer —
/// released by ``stheno_bridge_string_free``. Allocation and release both go
/// through Swift's allocator (`strdup`/`free` would work too, but the POSIX
/// names are deprecated on Windows).
func cString(_ string: String) -> UnsafeMutablePointer<CChar>? {
	let bytes = string.utf8CString
	let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bytes.count)
	bytes.withUnsafeBufferPointer { source in
		buffer.initialize(from: source.baseAddress!, count: bytes.count)
	}
	return buffer
}

/// The bridge's own version tag, so the host can log what it loaded.
@_cdecl("stheno_bridge_version")
public func stheno_bridge_version() -> UnsafeMutablePointer<CChar>? {
	cString("SthenoBridge 0.1")
}

/// Releases a string returned by any `stheno_bridge_*` function.
@_cdecl("stheno_bridge_string_free")
public func stheno_bridge_string_free(_ pointer: UnsafeMutablePointer<CChar>?) {
	pointer?.deallocate()
}

/// Converts a speed between units — Stheno's `Speed`. Units are the
/// `SpeedUnit` raw values: `"km/h"`, `"mph"`, `"kn"`.
/// - Returns: The converted value, or NaN when a unit is unknown.
@_cdecl("stheno_bridge_convert_speed")
public func stheno_bridge_convert_speed(
	_ value: Double,
	_ from: UnsafePointer<CChar>?,
	_ to: UnsafePointer<CChar>?
) -> Double {
	guard let from, let to,
		let fromUnit = SpeedUnit(rawValue: String(cString: from)),
		let toUnit = SpeedUnit(rawValue: String(cString: to))
	else { return .nan }
	return Speed(value: value, unit: fromUnit).converted(to: toUnit)
}

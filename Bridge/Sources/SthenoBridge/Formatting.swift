// Metric display formatting for the C ABI — Stheno's conversions and
// renderings, applied per metric name the way the Swift app's UnitFormatter
// does, so the .NET instrument pills show the very same strings.

internal import Foundation
internal import Stheno

/// What `stheno_bridge_format_metric` returns: the rendered value and unit.
private struct FormattedPayload: Encodable {
	let value: String
	let unit: String
}

/// Formats a canonical metric value for display, honouring the unit
/// preferences — the same Stheno conversions the Swift app applies.
///
/// Canonical inputs are BoatToolsKit's: speeds in knots, depths/heights in
/// metres, temperatures in °C, angles in degrees.
///
/// - Parameters:
///   - name: The metric name (e.g. `SOG`, `depth`, `AWA`,
///     `engine.0.coolantTemperature`).
///   - value: The canonical value.
///   - knotsSpeed: 1 to keep speeds in knots, 0 for the system unit.
///   - nauticalDistance: 1 for nautical miles, 0 for the system unit.
///   - metricSystem: 1 when the device uses the metric system (drives the
///     non-nautical fallbacks: km/h vs mph, metres vs feet, °C vs °F).
/// - Returns: JSON `{"value","unit"}` to release with
///   `stheno_bridge_string_free`.
@_cdecl("stheno_bridge_format_metric")
public func stheno_bridge_format_metric(
	_ name: UnsafePointer<CChar>?,
	_ value: Double,
	_ knotsSpeed: Int32,
	_ nauticalDistance: Int32,
	_ metricSystem: Int32
) -> UnsafeMutablePointer<CChar>? {
	let metric = name.map { String(cString: $0) } ?? ""
	let formatted = format(
		metric: metric, value: value,
		knots: knotsSpeed != 0, nautical: nauticalDistance != 0, isMetric: metricSystem != 0)
	let payload = FormattedPayload(value: formatted.value, unit: formatted.unit)
	guard let data = try? JSONEncoder().encode(payload) else {
		return cString(#"{"value":"","unit":""}"#)
	}
	return cString(String(decoding: data, as: UTF8.self))
}

/// The name → format mapping, mirroring the Swift app's `UnitFormatter`.
private func format(
	metric: String, value: Double, knots: Bool, nautical: Bool, isMetric: Bool
) -> Formatted {
	switch metric {
	case "SOG", "STW", "AWS", "TWS", "TWS.gust", "windGust", "navigation.vmg":
		let decimals = metric == "SOG" || metric == "STW" || metric == "navigation.vmg" ? 1 : 0
		let target: Speed.Format =
			knots
			? .knots(decimals: decimals)
			: isMetric ? .kilometersPerHour(decimals: decimals) : .milesPerHour(decimals: decimals)
		return Speed(value: value, unit: .knots).formatted(as: target)
	case "depth", "altitude":
		let distance = Distance(value: value, unit: .meters)
		return isMetric
			? distance.formatted(as: .meters(decimals: 1))
			: distance.formatted(as: .feet(decimals: 1))
	case "COG", "HDG", "AWA", "TWA", "heading", "TWD":
		return Angle(degrees: value).formatted(as: .degrees(decimals: 0))
	case "lat", "lon":
		// Coordinates keep their decimal-degree rendering here; the chart is
		// the place for fancier styles.
		return Formatted(formattedNumber(value, decimals: 5), "°")
	case let name where name.hasSuffix("emperature") || name.hasPrefix("temperature.") || name == "seaTemp":
		let temperature = Temperature(value: value, unit: .celsius)
		return isMetric
			? temperature.formatted(as: .celsius(decimals: 0))
			: temperature.formatted(as: .fahrenheit(decimals: 0))
	case "log", "tripLog":
		let distance = Distance(value: value, unit: .meters)
		if nautical { return distance.formatted(as: .nauticalMiles(decimals: 1)) }
		return distance.formatted(as: isMetric ? .kilometers(decimals: 1) : .miles(decimals: 1))
	case "log.trip", "log.total", "navigation.distanceToWaypoint", "navigation.xte":
		// BoatToolsKit's water-log and route distances are canonically in
		// nautical miles (unlike the metre-canonical `log`/`tripLog` above).
		let decimals = metric == "navigation.xte" ? 2 : 1
		let distance = Distance(value: value, unit: .nauticalMiles)
		if nautical { return distance.formatted(as: .nauticalMiles(decimals: decimals)) }
		return distance.formatted(
			as: isMetric ? .kilometers(decimals: decimals) : .miles(decimals: decimals))
	default:
		return Formatted(formattedNumber(value, decimals: 1))
	}
}

/// Mirrors Stheno's internal fixed-decimal renderer (kept private there).
private func formattedNumber(_ value: Double, decimals: Int) -> String {
	let places = max(0, decimals)
	guard places > 0 else { return String(Int(value.rounded())) }
	let factor = pow(10.0, Double(places))
	let rounded = (value * factor).rounded() / factor
	var text = String(rounded)
	if let dot = text.firstIndex(of: ".") {
		let fraction = text.distance(from: text.index(after: dot), to: text.endIndex)
		if fraction < places {
			text += String(repeating: "0", count: places - fraction)
		}
	}
	return text
}

/// What `stheno_bridge_format_coordinate` returns.
private struct CoordinatePayload: Encodable {
	let latitude: String
	let longitude: String
}

/// Formats a coordinate pair per the preferred style — Stheno's renderings,
/// identical to the Swift app's.
/// - Parameter style: 0 decimal, 1 degrees+minutes, 2 degrees+minutes+seconds.
/// - Returns: JSON `{"latitude","longitude"}` to release with
///   `stheno_bridge_string_free`.
@_cdecl("stheno_bridge_format_coordinate")
public func stheno_bridge_format_coordinate(
	_ latitude: Double, _ longitude: Double, _ style: Int32
) -> UnsafeMutablePointer<CChar>? {
	let coordinate = Coordinate(latitude: latitude, longitude: longitude)
	let pair: (latitude: String, longitude: String) =
		switch style {
		case 1: coordinate.formatted(as: .degreesMinutes())
		case 2: coordinate.formatted(as: .degreesMinutesSeconds)
		default: coordinate.formatted(as: .decimal())
		}
	let payload = CoordinatePayload(latitude: pair.latitude, longitude: pair.longitude)
	guard let data = try? JSONEncoder().encode(payload) else {
		return cString(#"{"latitude":"","longitude":""}"#)
	}
	return cString(String(decoding: data, as: UTF8.self))
}

/// The Beaufort force for a wind speed in knots — Stheno's scale, the same
/// "F5" figure the Swift app shows.
@_cdecl("stheno_bridge_beaufort")
public func stheno_bridge_beaufort(_ knots: Double) -> Int32 {
	Int32(BeaufortScale(kilometersPerHour: knots * 1.852).rawValue)
}

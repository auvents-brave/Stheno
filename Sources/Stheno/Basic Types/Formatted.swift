/// A formatted quantity split into its value and its unit, so a UI can render
/// the value large and the unit small (or grey) — the value/unit split the
/// instrument read-outs use. `unit` is empty for formats that carry none (for
/// example a cardinal direction).
public struct Formatted: Equatable, Sendable {
    /// The value, already rendered — e.g. "12", "0.7", "NE".
    public let value: String
    /// The unit symbol — e.g. "kn", "nm", "°", "Bft" — or "" when there is none.
    public let unit: String

    /// Creates a formatted value / unit pair.
    public init(_ value: String, _ unit: String = "") {
        self.value = value
        self.unit = unit
    }

    /// Value and unit joined with a space — "12 kn" (just the value when no unit).
    public var text: String { unit.isEmpty ? value : "\(value) \(unit)" }
}

/// Renders a value with a fixed number of decimals — portably: no `NSLocalized`,
/// no `String(format:)`, no `NumberFormatter`, so it works on every Swift
/// platform (including Linux and WASI). The decimal separator is always ".".
func formattedNumber(_ value: Double, decimals: Int) -> String {
    let places = max(0, decimals)
    var factor = 1.0
    for _ in 0 ..< places { factor *= 10 }

    let scaled = (value * factor).rounded()          // value in 1/factor units
    let negative = scaled < 0
    let absScaled = abs(scaled)
    let integerPart = Int(absScaled / factor)
    let fractionPart = Int(absScaled.truncatingRemainder(dividingBy: factor))
    let sign = negative && (integerPart != 0 || fractionPart != 0) ? "-" : ""

    if places == 0 { return sign + String(integerPart) }

    var fraction = String(fractionPart)
    if fraction.count < places {
        fraction = String(repeating: "0", count: places - fraction.count) + fraction
    }
    return sign + String(integerPart) + "." + fraction
}

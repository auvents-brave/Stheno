import Foundation
import Testing

@testable import Stheno

@Suite("Volume Tests")
struct VolumeTests {
	@Test func `Litres to gallons conversion`() {
		let volume = Volume(value: 100, unit: .liters)
		// US and imperial gallons differ: 3.785 L vs 4.546 L.
		#expect(abs(volume.converted(to: .usGallons) - 26.417) < 0.001)
		#expect(abs(volume.converted(to: .imperialGallons) - 21.997) < 0.001)
	}

	@Test func `Cubic metres pivot through litres`() {
		let volume = Volume(value: 2, unit: .cubicMeters)
		#expect(volume.converted(to: .liters) == 2000)
		#expect(abs(volume.converted(to: .usGallons) - 528.344) < 0.001)
	}

	@Test func `Same unit returns original value`() {
		let volume = Volume(value: 42.5, unit: .liters)
		#expect(volume.converted(to: .liters) == 42.5)
	}

	@Test func `Volume formatted output`() {
		let volume = Volume(value: 200, unit: .liters)
		let us = volume.formatted(as: .usGallons())
		#expect(us.value == "53")
		#expect(us.unit == "gal")
		let imperial = volume.formatted(as: .imperialGallons())
		#expect(imperial.value == "44")
		#expect(imperial.unit == "gal Imp.")
		let litres = volume.formatted(as: .liters())
		#expect(litres.value == "200")
		#expect(litres.unit == "L")
	}

	@Test func `Preferred unit follows the measurement system`() {
		#expect(VolumeUnit.preferred(for: Locale(identifier: "fr_FR")) == .liters)
		#expect(VolumeUnit.preferred(for: Locale(identifier: "en_US")) == .usGallons)
		#expect(VolumeUnit.preferred(for: Locale(identifier: "en_GB")) == .imperialGallons)
		#expect(VolumeUnit.preferred(for: Locale(identifier: "de_DE")) == .liters)
	}

	@Test func `Preferred unit honours a measurement-system override`() {
		// A device can switch its measurement system independently of the region.
		#expect(VolumeUnit.preferred(for: Locale(identifier: "fr-FR-u-ms-ussystem")) == .usGallons)
		#expect(VolumeUnit.preferred(for: Locale(identifier: "en-GB-u-ms-metric")) == .liters)
	}

	#if canImport(Darwin)
		@Test func `Preferred unit knows regional exceptions (Apple platforms)`() {
			// Myanmar and Liberia read litres despite non-metric measurement systems.
			#expect(VolumeUnit.preferred(for: Locale(identifier: "my_MM")) == .liters)
			#expect(VolumeUnit.preferred(for: Locale(identifier: "en_LR")) == .liters)
			// ICU keeps litres for a metric region switched to the UK system —
			// the UK itself sells fuel in litres; only a GB region defaults to
			// imperial gallons. (The portable fallback maps `.uk` to imperial
			// gallons instead, lacking this per-region data.)
			#expect(VolumeUnit.preferred(for: Locale(identifier: "fr-FR-u-ms-uksystem")) == .liters)
		}
	#endif
}

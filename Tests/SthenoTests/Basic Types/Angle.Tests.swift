import Foundation
import Testing

@testable import Stheno

@Suite("Angle Tests")
struct AngleTests {
    @Test("Angle normalizes negative degrees")
    func normalizesNegativeDegrees() {
        let angle = Angle(degrees: -45)
        #expect(angle.value == 315)
    }

    @Test("Angle normalizes over-360 degrees")
    func normalizesOver360() {
        let angle = Angle(degrees: 450)
        #expect(angle.value == 90)
    }

    @Test("Cardinal direction mapping")
    func cardinalMapping() {
        #expect(Angle(degrees: 0).cardinalDirection == .N)
        #expect(Angle(degrees: 45).cardinalDirection == .NE)
        #expect(Angle(degrees: 90).cardinalDirection == .E)
        #expect(Angle(degrees: 225).cardinalDirection == .SW)
    }

    @Test("Cardinal direction from string")
    func cardinalFromString() {
        let angle = Angle(cardinalDirection: " sW ")
        #expect(angle?.value == 225)
    }

    @Test("Formatted angle outputs")
    func formattedOutputs() {
        let angle = Angle(degrees: 30)
        let degrees = angle.formattedDegrees
        #expect(degrees.value == 30)
        #expect(degrees.unit == "°")
        #expect(angle.formattedCardinal == "NE")
    }
}

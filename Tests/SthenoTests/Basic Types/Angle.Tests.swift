import Foundation
import Testing

@testable import Stheno

@Suite("Angle Tests")
struct AngleTests {
    @Test func `Angle normalizes negative degrees`() {
        let angle = Angle(degrees: -45)
        #expect(angle.value == 315)
    }

    @Test func `Angle normalizes over-360 degrees`() {
        let angle = Angle(degrees: 450)
        #expect(angle.value == 90)
    }

    @Test func `Cardinal direction mapping`() {
        #expect(Angle(degrees: 0).cardinalDirection == .N)
        #expect(Angle(degrees: 45).cardinalDirection == .NE)
        #expect(Angle(degrees: 90).cardinalDirection == .E)
        #expect(Angle(degrees: 225).cardinalDirection == .SW)
    }

    @Test func `Cardinal direction from string`() {
        let angle = Angle(cardinalDirection: " sW ")
        #expect(angle?.value == 225)
    }

    @Test func `Formatted angle outputs`() {
        let angle = Angle(degrees: 30)
        let degrees = angle.formattedDegrees
        #expect(degrees.value == 30)
        #expect(degrees.unit == "°")
        #expect(angle.formattedCardinal == "NE")
    }
}

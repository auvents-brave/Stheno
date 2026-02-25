import Foundation
import Testing

@testable import Stheno

@Test func `Detect Xcode previews via environment`() {
    #expect(isRunningInPreviews == false)
}

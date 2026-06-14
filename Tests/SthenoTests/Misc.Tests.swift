import Foundation
import Testing

@testable import Stheno

@Test func `Detect Xcode previews via environment`() {
	#expect(isRunningInPreviews == false)
}

@Test func `Detect TestFlight via the App Store receipt`() {
	// The test host carries no sandbox receipt, so this is always false here —
	// the point is to exercise the receipt check on every platform.
	#expect(isTestFlight == false)
}

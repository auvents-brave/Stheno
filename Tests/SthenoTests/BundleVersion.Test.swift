import Foundation
import Testing

@testable import RabFoundation

@Test("Bundle+Version")
func BundleVersionTest() async throws {
    // Missing or bad CFBundle info in our app's Info.plist.
    #expect(Versioning.GetDisplayedVersion(nil) == "Unknown version")

    // Good Info.plist
    let bundle = Bundle.module
    guard let url = bundle.url(forResource: "TestInfo", withExtension: "plist"),
          let data = try? Data(contentsOf: url),
          let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
        Issue.record("Could not load TestInfo.plist")
        return
    }
    #expect(Versioning.GetDisplayedVersion(plist) == "1.0 (99)")

    // Call our Bundle extensions to get correct code coverage
    _ = Bundle.module.releaseVersion
    _ = Bundle.module.buildNumber
    _ = Bundle.module.displayedVersion
}

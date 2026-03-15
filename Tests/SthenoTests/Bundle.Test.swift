import Foundation
import Testing

@testable import Stheno

#if !os(WASI)
@Test func `Bundle info and display name`() async throws {
    // Missing or bad CFBundle info in our app's Info.plist.
    #expect(Versioning.getDisplayedVersion(nil) == "Unknown version")

    // Good Info.plist
    let bundle = Bundle.module
    guard let url = bundle.url(forResource: "TestInfo", withExtension: "plist"),
          let data = try? Data(contentsOf: url),
          let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
        Issue.record("Could not load TestInfo.plist")
        return
    }
	#expect(Versioning.getDisplayedVersion(plist) == "1.0 (99)")

	#expect(DisplayName.getDisplayName(MockBundle(
		base: [
			"CFBundleName": plist["CFBundleName"] ?? "",
			"CFBundleDisplayName": plist["CFBundleDisplayName"] ?? ""
		],
		localized: [:]
	)) == "Stheno Library")

	#expect(DisplayName.getDisplayName(MockBundle(
		base: [
			"CFBundleName": plist["CFBundleName"] ?? ""
		],
		localized: [:]
	)) == "Stheno")

	#expect(DisplayName.getDisplayName(MockBundle(
		base: [
			"CFBundleName": plist["CFBundleName"] ?? "",
			"CFBundleDisplayName": plist["CFBundleDisplayName"] ?? ""
		],
		localized: [
			"CFBundleName": "Sthenô",
			"CFBundleDisplayName": "Sthenô Librairie"
		]
	)) == "Sthenô Librairie")

	#expect(DisplayName.getDisplayName(MockBundle(
		base: [
			"CFBundleName": plist["CFBundleName"] ?? ""
		],
		localized: [
			"CFBundleName": "Sthenô"
		]
	)) == "Sthenô")

	#expect(DisplayName.getDisplayName(MockBundle(
		base: [:],
		localized: [:]
	)) != "")

    // Call our Bundle extensions to get correct code coverage
    _ = Bundle.module.releaseVersion
    _ = Bundle.module.buildNumber
	_ = Bundle.module.displayedVersion
	_ = Bundle.module.displayName
}
#endif

private final class MockBundle: Bundle, @unchecked Sendable {
	private let base: [String: Any]?
	private let localized: [String: Any]?

	init(base: [String: Any]?, localized: [String: Any]?) {
		self.base = base
		self.localized = localized
		super.init()
	}

	override var infoDictionary: [String : Any]? { base }
	override var localizedInfoDictionary: [String : Any]? { localized }
}

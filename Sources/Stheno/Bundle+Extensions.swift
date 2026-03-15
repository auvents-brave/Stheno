import Foundation

/**
  Extension to Bundle to access versioning information and display name  from the app's Info.plist.

  Provides convenient accessors for version numbers in an application's Info.plist via Bundle extensions.
  This extension adds computed properties to retrieve the app's release and build version numbers.
  ## Usage
 ```swift
    let version = Bundle.main.displayedVersion
 ```

  > Tip: To show the version string on the application's Settings pane, see <doc:DisplayAppVersion>.
   */
extension Bundle {
    /// The release version number of the app (from CFBundleShortVersionString in Info.plist).
    /// Returns nil if the value is not present.
    public var releaseVersion: String? {
        return Versioning.getReleaseVersion(infoDictionary)
    }

    /// The build version number of the app (from CFBundleVersion in Info.plist).
    /// Returns nil if the value is not present.
    public var buildNumber: String? {
        return Versioning.getBuildNumber(infoDictionary)
    }

    /// A formatted version string for display purposes, combining the release version number and the build number.
    /// - Returns: A string in the form 1.2.3 (456). if available; otherwise, returns "Unknown version".
    public var displayedVersion: String {
        return Versioning.getDisplayedVersion(infoDictionary)
    }

    /// The user-visible application name from Info.plist.
    /// 	This file adds a computed property on `Bundle` that returns the user‑visible
    /// 	application name. It looks up `CFBundleDisplayName` first and falls back to
    /// 	`CFBundleName` when a display name isn't provided. Localized values are
    /// 	preferred when available.
    ///
    /// 	The lookup order is:
    /// 	1. `localizedInfoDictionary["CFBundleDisplayName"]`
    /// 	2. `infoDictionary["CFBundleDisplayName"]`
    /// 	3. `localizedInfoDictionary["CFBundleName"]`
    /// 	4. `infoDictionary["CFBundleName"]`
    /// 	5. `ProcessInfo.processName` (as a last resort)

    /// 	Use this to consistently present the app's name in UI, settings, logs, or
    /// 	diagnostics, regardless of whether the name is localized or configured via
    /// 	`CFBundleDisplayName`.

    /// 	## Usage
    /// 	```swift
    /// 	let name = Bundle.main.displayName
    public var displayName: String {
        return DisplayName.getDisplayName(self)
    }
}

internal protocol BundleInfoProviding {
    var infoDictionary: [String: Any]? { get }
    var localizedInfoDictionary: [String: Any]? { get }
}

extension Bundle: BundleInfoProviding {}

internal struct Versioning {
    static func getReleaseVersion(_ dict: [String: Any]?) -> String? {
        return dict?["CFBundleShortVersionString"] as? String
    }

    static func getBuildNumber(_ dict: [String: Any]?) -> String? {
        return dict?["CFBundleVersion"] as? String
    }

    static func getDisplayedVersion(_ dict: [String: Any]?) -> String {
        guard let release = getReleaseVersion(dict), let build = getBuildNumber(dict) else {
            return "Unknown version"
        }
        return "\(release) (\(build))"
    }
}

internal struct DisplayName {
    static func getDisplayName(_ bundle: any BundleInfoProviding) -> String {
        guard let localizedDisplayName = bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String else {
            guard let displayName = bundle.infoDictionary?["CFBundleDisplayName"] as? String else {
                guard let localizedBundleName = bundle.localizedInfoDictionary?["CFBundleName"] as? String else {
                    guard let bundleName = bundle.infoDictionary?["CFBundleName"] as? String else {
                        return ProcessInfo.processInfo.processName
                    }
                    return bundleName
                }
                return localizedBundleName
            }
            return displayName
        }
        return localizedDisplayName
    }
}

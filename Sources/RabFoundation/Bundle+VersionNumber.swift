import Foundation

/**
  Extension to Bundle to access versioning information from the app's Info.plist.

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
        return Versioning.GetReleaseVersion(infoDictionary)
    }

    /// The build version number of the app (from CFBundleVersion in Info.plist).
    /// Returns nil if the value is not present.
    public var buildNumber: String? {
        return Versioning.GetBuildNumber(infoDictionary)
    }

    /// A formatted version string for display purposes, combining the release version number and the build number.
    /// - Returns: A string in the form 1.2.3 (456). if available; otherwise, returns "Unknown version".
    public var displayedVersion: String {
        return Versioning.GetDisplayedVersion(infoDictionary)
    }
}

internal struct Versioning {
    static func GetReleaseVersion(_ dict: [String: Any]?) -> String? {
        return dict?["CFBundleShortVersionString"] as? String
    }

    static func GetBuildNumber(_ dict: [String: Any]?) -> String? {
        return dict?["CFBundleVersion"] as? String
    }

    static func GetDisplayedVersion(_ dict: [String: Any]?) -> String {
        guard let release = GetReleaseVersion(dict), let build = GetBuildNumber(dict) else {
            return "Unknown version"
        }
        return "\(release) (\(build))"
    }
}

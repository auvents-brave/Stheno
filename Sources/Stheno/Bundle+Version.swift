public import Foundation

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

  /// A formatted version string combining the release version and build
  /// number, suitable for display.
  ///
  /// ```swift
  /// let version = Bundle.main.displayedVersion
  /// // → "1.2.3 (456)"
  /// ```
  ///
  /// - Returns: `"<release> (<build>)"` when both values are present,
  ///   otherwise `"Unknown version"`.
  public var displayedVersion: String {
    return Versioning.getDisplayedVersion(infoDictionary)
  }
}

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

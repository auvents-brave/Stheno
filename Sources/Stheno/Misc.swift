internal import Foundation

/// Indicates whether the current process is running inside Xcode SwiftUI previews.
public var isRunningInPreviews: Bool {
	ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

/// Indicates whether the app is running via TestFlight.
public var isTestFlight: Bool {
	Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
}

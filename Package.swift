// swift-tools-version: 6.1

import Foundation
import PackageDescription

let swiftSettings: [SwiftSetting] =
	ProcessInfo.processInfo.environment["RUNNER"] == "VSCode" ? [.define("VSCode")] :
	(ProcessInfo.processInfo.environment["XCODE_VERSION_ACTUAL"] != nil ? [.define("Xcode")] : [])

var prods: [Product] = [
	.library(
		name: "Stheno",
		type: .static,
		targets: ["Stheno"]
	),
]

var deps: [Package.Dependency] = [
	.package(
		url: "https://github.com/apple/swift-log",
		from: "1.6.0"
	),
	.package(
		url: "https://github.com/neallester/swift-log-testing",
		from: "0.0.1"
	),
	.package(
		url: "https://github.com/malcommac/SwiftDate",
		from: "6.3.1",
	),
]

var targs: [Target] = [
	.target(
		name: "Stheno",
		dependencies: [
			.product(name: "Logging", package: "swift-log"),
			.product(
				name: "SwiftDate",
				package: "SwiftDate",
				condition: .when(
					platforms: [
						.macOS,
						.iOS,
						.tvOS,
						.watchOS,
						.macCatalyst,
						.visionOS
					]
				)
			)
		],
		resources: [
			.process("Resources"),
		],
		swiftSettings: swiftSettings,
	),

	.testTarget(
		name: "SthenoTests",
		dependencies: [
			"Stheno",
			.product(
				name: "SwiftLogTesting",
				package: "swift-log-testing",
				condition: .when(
					platforms: [
						// Intentionally exclude `.wasi` because `swift-log-testing` relies on Dispatch.
						.macOS,
						.iOS,
						.tvOS,
						.watchOS,
						.macCatalyst,
						.visionOS,
						.linux,
						.windows,
						.android
					]
				)
			),
		],
		resources: [
			.process("TestInfo.plist"),
		],
		swiftSettings: swiftSettings,
	),
]

// Previous minimum platforms: .macOS(.v10_13), .macCatalyst(.v13), .iOS(.v12), .tvOS(.v12), .watchOS(.v5), .visionOS(.v1)

let package = Package(
	name: "Stheno",
	defaultLocalization: "en",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v17),
		.iOS(.v17),
		.tvOS(.v17),
		.watchOS(.v10),
		.visionOS(.v1),
	],

	products: prods,

	dependencies: deps,

	targets: targs,

	swiftLanguageModes: [.v6],
)

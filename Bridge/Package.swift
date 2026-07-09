// swift-tools-version: 6.1

import PackageDescription

// The native bridge for non-Swift hosts (P/Invoke, ctypes, JNI…): Stheno
// compiled into one dynamic library exposing a C ABI. A nested package so the
// main library product and its consumers are untouched; build it with
// `swift build -c release` from this directory.
let package = Package(
	name: "SthenoBridge",
	platforms: [.macOS(.v13)],
	products: [
		.library(name: "SthenoBridge", type: .dynamic, targets: ["SthenoBridge"])
	],
	dependencies: [
		.package(path: "..")
	],
	targets: [
		.target(
			name: "SthenoBridge",
			dependencies: [.product(name: "Stheno", package: "Stheno")],
			swiftSettings: [
				.enableUpcomingFeature("InternalImportsByDefault"),
				.enableUpcomingFeature("ExistentialAny"),
				.swiftLanguageMode(.v6),
			]
		)
	]
)

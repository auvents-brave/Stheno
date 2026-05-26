// swift-tools-version: 6.1

import Foundation
import PackageDescription

var swiftSettings: [SwiftSetting] = [
	.enableUpcomingFeature("InternalImportsByDefault"),
	.enableUpcomingFeature("ExistentialAny"),
]
if ProcessInfo.processInfo.environment["RUNNER"] == "VSCode" {
	swiftSettings.append(.define("VSCode"))
} else if ProcessInfo.processInfo.environment["XCODE_VERSION_ACTUAL"] != nil {
	swiftSettings.append(.define("Xcode"))
}

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
]

// Bonjour/mDNS discovery back-end by platform:
//   - Apple (iOS/macOS/watchOS/tvOS/visionOS): Network.framework NWBrowser (no extra dep)
//   - Windows: native DnsServiceBrowse from windns.h (links Dnsapi.dll, no install required)
//   - Linux:   dns_sd C API via Avahi compatibility layer (Cdns_sd system library target)
var sthenoDeps: [Target.Dependency] = [
	.product(name: "Logging", package: "swift-log"),
]

#if os(Linux)
sthenoDeps.append("Cdns_sd")
#endif

var targs: [Target] = [
	.target(
		name: "Stheno",
		dependencies: sthenoDeps,
		resources: [
			.process("Resources"),
		],
		swiftSettings: swiftSettings,
		linkerSettings: [
			// Windows: BonjourDiscovery uses DnsServiceBrowse/DnsServiceResolve from Dnsapi.dll.
			.linkedLibrary("dnsapi", .when(platforms: [.windows])),
			// Linux: --as-needed drops -ldns_sd from DT_NEEDED (loaded at runtime via dlopen).
			// The binary launches even when libdns_sd.so is not installed.
			.unsafeFlags(["-Xlinker", "--as-needed"], .when(platforms: [.linux])),
		]
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

#if os(Linux)
targs.append(
	.systemLibrary(
		name: "Cdns_sd",
		pkgConfig: "avahi-compat-libdns_sd",
		providers: [.apt(["libavahi-compat-libdnssd-dev"])]
	)
)
#endif

let package = Package(
	name: "Stheno",
	defaultLocalization: "en",
	platforms: [
		.macOS(.v13), .macCatalyst(.v16), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)
	],

	products: prods,

	dependencies: deps,

	targets: targs,

	swiftLanguageModes: [.v6],
)

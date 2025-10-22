// swift-tools-version: 6.2

import PackageDescription
import Foundation

#if canImport(XcodeProject)
let isXcode = true
#else
let isXcode = false
#endif
// or let isXcode = ProcessInfo.processInfo.environment["XCODE_VERSION_ACTUAL"] != nil

var prods: [Product] = [
    .library(
        name: "Stheno",
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

var targs: [Target] = [
  .target(
    name: "Stheno",
    dependencies: [
      .product(name: "Logging", package: "swift-log"),
    ],
	resources: [
		.process("Resources")
	],
	swiftSettings: isXcode ? [
		.define("XCODE")
	] : []
  ),

  .testTarget(
    name: "SthenoTests",
    dependencies: [
      "Stheno",
      .product(name: "SwiftLogTesting", package: "swift-log-testing"),
    ],
    resources: [
      .process("TestInfo.plist"),
    ]
  ),
]

let package = Package(
    name: "Stheno",
	defaultLocalization: "en",
    platforms: [
        .macOS(.v11),
        .macCatalyst(.v14),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7),
        .visionOS(.v1),
    ],

    products: prods,

    dependencies: deps,

    targets: targs,
    
    swiftLanguageModes: [ .v6 ],
)

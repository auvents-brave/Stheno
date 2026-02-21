# Sthenô

> **Sthenô** (Σθεννώ), another of the three Gorgon sisters in Greek mythology and sister to **Euryale** and **Medusa**, is traditionally depicted as immortal. Her name conveys “strength” or “might,” underscoring themes of endurance and power. This reference aligns with the library’s focus on robust, reusable components.

Sthenô is a small, cross-platform Swift package that consolidates reusable, context-independent components. It focuses on well-scoped building blocks with clear APIs, thorough DocC documentation, and solid unit test coverage, designed to be adopted piecemeal across apps, frameworks, and tools.

Sthenô depends only on [swift-log](https://github.com/apple/swift-log) for structured logging, ensuring consistent and configurable diagnostics across platforms while keeping the overall dependency footprint minimal.

Continuous Integration (CI) is handled through GitHub Actions, which automatically builds, tests, and analyzes the codebase using CodeQL to ensure quality, consistency, and cross-platform reliability.

![Swift](https://img.shields.io/badge/Swift-6.1-orange?logo=swift) [![CodeQL](https://github.com/auvents-brave/Stheno/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/codeql.yml)

Documentation is available directly in Xcode and VS Code (via Swift symbol/documentation support), and online as DocC: [![DocC](https://img.shields.io/badge/docs-available-brightgreen)](https://auvents-brave.github.io/Stheno/).

## Supported Platforms

Minimum Apple platform versions declared by the package:

- macOS 10.13+
- Mac Catalyst 13.0+
- iOS 12.0+
- iPadOS 12.0+
- tvOS 12.0+
- watchOS 5.0+
- visionOS 1.0+

Additional supported non-Apple platforms:

- Linux
- Windows
- WebAssembly (WASI)
- Android

## CI Status

| Platform | Status |
|---|---|
| ![macOS](https://img.shields.io/badge/macOS-000000?logo=apple) | [![macOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-macos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-macos.yml) |
| ![Mac Catalyst](https://img.shields.io/badge/Mac_Catalyst-1C1C1E?logo=apple) | [![Mac Catalyst](https://github.com/auvents-brave/Stheno/actions/workflows/apple-maccatalyst.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-maccatalyst.yml) |
| ![iOS](https://img.shields.io/badge/iOS-0A84FF?logo=apple) | [![iOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ios.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ios.yml) |
| ![iPadOS](https://img.shields.io/badge/iPadOS-0A84FF?logo=apple) | [![iPadOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ipados.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ipados.yml) |
| ![tvOS](https://img.shields.io/badge/tvOS-1C1C1E?logo=apple) | [![tvOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-tvos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-tvos.yml) |
| ![watchOS](https://img.shields.io/badge/watchOS-1C1C1E?logo=apple) | [![watchOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-watchos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-watchos.yml) |
| ![visionOS](https://img.shields.io/badge/visionOS-5E5CE6?logo=apple) | [![visionOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-visionos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-visionos.yml) |
| ![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black) | [![Linux](https://github.com/auvents-brave/Stheno/actions/workflows/linux.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/linux.yml) |
| ![Windows](https://img.shields.io/badge/Windows-0078D6?logo=windows&logoColor=white) | [![Windows](https://github.com/auvents-brave/Stheno/actions/workflows/windows.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/windows.yml) |
| ![WebAssembly](https://img.shields.io/badge/WebAssembly-654FF0?logo=webassembly) | [![WebAssembly](https://github.com/auvents-brave/Stheno/actions/workflows/wasm.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/wasm.yml) |
| ![Android](https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white) | [![Android](https://github.com/auvents-brave/Stheno/actions/workflows/android.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/android.yml) |

## Public API Documentation

### Core Domain Types (measurement, weather, time)

These types support practical conversion workflows across common units (for example, `°C`/`°F` and kilometers/miles) and marine-oriented units and conventions, including nautical miles, knots, cardinal angles, and Beaufort wind scale mapping.

- [`Angle`](https://auvents-brave.github.io/Stheno/documentation/stheno/angle/) - An angle in degrees normalized to the [0, 360) range.
- [`Coordinate`](https://auvents-brave.github.io/Stheno/documentation/stheno/coordinate/) - Represents geographical coordinates (latitude and longitude).
- [`Distance`](https://auvents-brave.github.io/Stheno/documentation/stheno/distance/) - Represents a distance value with unit conversions and formatting helpers.
- [`Speed`](https://auvents-brave.github.io/Stheno/documentation/stheno/speed/) - Represents a speed value with conversion and formatting helpers.
- [`Temperature`](https://auvents-brave.github.io/Stheno/documentation/stheno/temperature/) - Represents a temperature value with conversion and formatting helpers.
- [`DateTime`](https://auvents-brave.github.io/Stheno/documentation/stheno/datetime/) - Represents a date with helpers for parsing and formatting.

### Geolocation

- [`Geo`](https://auvents-brave.github.io/Stheno/documentation/stheno/geo/) - Utility functions for geographic calculations (distance, bearings, etc.).
- `CLLocationCoordinate2D.init(_ fix: Coordinate)` - Convenience interop for converting a `Coordinate` into CoreLocation coordinates.

### Colors and UI Interop

- [`Color`](https://auvents-brave.github.io/Stheno/documentation/stheno/color/) - Cross-platform color support with strict HTML hex parsing/formatting and native bridging (`Color`, `UIColor`, `NSColor`) when available.

### Utility APIs

- [`Throttled`](https://auvents-brave.github.io/Stheno/documentation/stheno/throttled/) - A property wrapper that throttles updates to its wrapped value.
- `CleanHTML(from:)` - Removes all known HTML tags from a string and decodes common HTML entities to their Unicode equivalents.
- `containsHTML(_:)` - Returns true when the input contains HTML tags/entities that `CleanHTML(from:)` would transform.
- `downloadURLasString(from:completion:)` - Downloads the contents of the given URL and decodes it as a UTF-8 `String`.
- `InterceptingStdOut(to:encoding:body:)` (Darwin, async) - Additionally writes any data written to standard output into the given output stream.
- `isRunningInPreviews` - Indicates whether code is running under Xcode previews (`XCODE_RUNNING_FOR_PREVIEWS == "1"`).

### Bundle Version APIs

- `Bundle.releaseVersion` - The release version number of the app (from CFBundleShortVersionString in Info.plist).
- `Bundle.buildNumber` - The build version number of the app (from CFBundleVersion in Info.plist).
- `Bundle.displayedVersion` - A formatted version string for display purposes, combining the release version number and the build number.

# Sthenô

> **Sthenô** (Σθεννώ), another of the three Gorgon sisters in Greek mythology and sister to **Euryale** and **Medusa**, is traditionally depicted as immortal. Her name conveys “strength” or “might,” underscoring themes of endurance and power. This reference aligns with the library’s focus on robust, reusable components.

Sthenô is a small, cross-platform Swift package that consolidates reusable, context-independent components. It focuses on well-scoped building blocks with clear APIs, thorough DocC documentation, and solid unit test coverage, designed to be adopted piecemeal across apps, frameworks, and tools.

Sthenô depends only on [swift-log](https://github.com/apple/swift-log) for structured logging, ensuring consistent and configurable diagnostics across platforms while keeping the overall dependency footprint minimal.

Continuous Integration (CI) is handled through GitHub Actions, which automatically builds, tests, generates documentation, and analyzes the codebase using CodeQL and SonarQube to ensure quality, consistency, and cross-platform reliability.

![Swift](https://img.shields.io/badge/Swift-6.1+-orange?logo=swift)

[![CodeQL](https://github.com/auvents-brave/Stheno/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/codeql.yml)

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=auvents-brave_Stheno&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=auvents-brave_Stheno)

[![DocC](https://img.shields.io/badge/DocC-available-brightgreen)](https://auvents-brave.github.io/Stheno/)

Documentation is available directly in Xcode and VS Code, and [online](https://auvents-brave.github.io/Stheno/) as DocC.

## Platforms and CI

| Platform | CI Status |
|---|---|
| ![macOS](https://img.shields.io/badge/macOS-111111?logo=apple&logoColor=white) ![min OS 10.13+](https://img.shields.io/badge/min%20OS-10.13%2B-444444) | [![macOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-macos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-macos.yml) |
| ![Mac Catalyst](https://img.shields.io/badge/Mac_Catalyst-111111?logo=apple&logoColor=white) ![min OS 13.0+](https://img.shields.io/badge/min%20OS-13.0%2B-444444) | [![Mac Catalyst](https://github.com/auvents-brave/Stheno/actions/workflows/apple-maccatalyst.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-maccatalyst.yml) |
| ![iOS](https://img.shields.io/badge/iOS-111111?logo=apple&logoColor=white) ![min OS 12.0+](https://img.shields.io/badge/min%20OS-12.0%2B-444444) | [![iOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ios.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ios.yml) |
| ![iPadOS](https://img.shields.io/badge/iPadOS-111111?logo=apple&logoColor=white) ![min OS 12.0+](https://img.shields.io/badge/min%20OS-12.0%2B-444444) | [![iPadOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ipados.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ipados.yml) |
| ![tvOS](https://img.shields.io/badge/tvOS-111111?logo=apple&logoColor=white) ![min OS 12.0+](https://img.shields.io/badge/min%20OS-12.0%2B-444444) | [![tvOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-tvos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-tvos.yml) |
| ![watchOS](https://img.shields.io/badge/watchOS-111111?logo=apple&logoColor=white) ![min OS 5.0+](https://img.shields.io/badge/min%20OS-5.0%2B-444444) | [![watchOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-watchos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-watchos.yml) |
| ![visionOS](https://img.shields.io/badge/visionOS-111111?logo=apple&logoColor=white) ![min OS 1.0+](https://img.shields.io/badge/min%20OS-1.0%2B-444444) | [![visionOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-visionos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-visionos.yml) |
| ![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black) | [![Linux](https://github.com/auvents-brave/Stheno/actions/workflows/linux.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/linux.yml) |
| ![Windows](https://img.shields.io/badge/Windows-0078D6?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgZmlsbD0id2hpdGUiPjxyZWN0IHg9IjAiIHk9IjAiIHdpZHRoPSIxMSIgaGVpZ2h0PSIxMSIvPjxyZWN0IHg9IjEzIiB5PSIwIiB3aWR0aD0iMTEiIGhlaWdodD0iMTEiLz48cmVjdCB4PSIwIiB5PSIxMyIgd2lkdGg9IjExIiBoZWlnaHQ9IjExIi8+PHJlY3QgeD0iMTMiIHk9IjEzIiB3aWR0aD0iMTEiIGhlaWdodD0iMTEiLz48L3N2Zz4=&logoColor=white) | [![Windows](https://github.com/auvents-brave/Stheno/actions/workflows/windows.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/windows.yml) |
| ![WebAssembly](https://img.shields.io/badge/WebAssembly-654FF0?logo=webassembly&logoColor=white) | [![WebAssembly](https://github.com/auvents-brave/Stheno/actions/workflows/wasm.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/wasm.yml) |
| ![Android](https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white) | [![Android](https://github.com/auvents-brave/Stheno/actions/workflows/android.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/android.yml) |

## Public API

### Core Domain Types (measurement, time, angle, speed...)

These types support practical conversion workflows across common units (for example, `°C`/`°F` and kilometers/miles) and marine-oriented units and conventions, including nautical miles, knots, cardinal angles, and Beaufort wind scale mapping.

Many ISO date parsers follow RFC 3339, which is a strict subset of ISO 8601.
DateTime implementations are more permissive and accept additional ISO 8601 variants, such as the absence of a time zone or the use of a comma for fractional seconds.


- [`Angle`](https://auvents-brave.github.io/Stheno/documentation/stheno/angle/) - An angle in degrees normalized to the [0, 360) range.
- [`Coordinate`](https://auvents-brave.github.io/Stheno/documentation/stheno/coordinate/) - Represents geographical coordinates (latitude and longitude).
- [`Distance`](https://auvents-brave.github.io/Stheno/documentation/stheno/distance/) - Represents a distance value with unit conversions and formatting helpers.
- [`DateTime`](https://auvents-brave.github.io/Stheno/documentation/stheno/datetime/) - Represents a date with helpers for parsing and formatting helpers.
- [`Speed`](https://auvents-brave.github.io/Stheno/documentation/stheno/speed/) - Represents a speed value with conversion and formatting helpers.
- [`Temperature`](https://auvents-brave.github.io/Stheno/documentation/stheno/temperature/) - Represents a temperature value with conversion and formatting helpers.


### Geolocation

- [`Geo`](https://auvents-brave.github.io/Stheno/documentation/stheno/geo/) - Utility functions for geographic calculations (great-circle distance, bearings, etc.).

### Colors

- [`Color`](https://auvents-brave.github.io/Stheno/documentation/stheno/color/) - Cross-platform color support with strict HTML hex parsing/formatting and native bridging (`Color`, `UIColor`, `NSColor`) when available.

### HTML

- [`CleanHTML(from:)`](https://auvents-brave.github.io/Stheno/documentation/stheno/cleanhtml(from:))  - Removes all known HTML tags from a string and decodes common HTML character entities to their Unicode equivalents.

Example:
```swift
let result = CleanHTML(from: "<body><h1>Un &oelig;il &eacute;veill&eacute;</h1>&amp; exemple &agrave;  &lt;10&euro;&gt;</body>")
print(result)
```
Output:
```
Un œil éveillé & exemple à <10€>
```

### Misc Utilities

- Extension to [`Bundle`](https://auvents-brave.github.io/Stheno/documentation/stheno/foundation/bundle) to access versioning information from the app’s Info.plist.

- [`downloadURLasString`](https://auvents-brave.github.io/Stheno/documentation/stheno/downloadurlasstring(from:completion:)) - Downloads the contents of the given URL and decodes it as a UTF-8 `String`. (Not implemented on WASI)
> Use only the pure Toolchain, not [SwiftNIO](hhttps://github.com/apple/swift-nio), even on Linux or Windows.

- `isRunningInPreviews` - Indicates whether code is running under Xcode previews.

- [`Throttled`](https://auvents-brave.github.io/Stheno/documentation/stheno/throttled/) - A property wrapper that throttles updates to its wrapped value.


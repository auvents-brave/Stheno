# Sthenô

> **Sthenô** (Σθεννώ), another of the three Gorgon sisters in Greek mythology and sister to **Euryale** and **Medusa**, is traditionally depicted as immortal. Her name conveys “strength” or “might,” underscoring themes of endurance and power. This reference aligns with the library’s focus on robust, reusable components.

Sthenô is a small, cross-platform Swift package that consolidates reusable, context-independent components. It focuses on well-scoped building blocks with clear APIs, thorough DocC documentation, and solid unit test coverage, designed to be adopted piecemeal across apps, frameworks, and tools.

Sthenô depends only on [swift-log](https://github.com/apple/swift-log) for structured logging, ensuring consistent and configurable diagnostics across platforms while keeping the overall dependency footprint minimal.

Continuous Integration (CI) is handled through GitHub Actions, which automatically builds, tests, generates documentation, and analyzes the codebase using CodeQL and SonarQube to ensure quality, consistency, and cross-platform reliability.

![Swift](https://img.shields.io/badge/Swift-6.1+-orange?logo=swift)

[![CodeQL](https://github.com/auvents-brave/Stheno/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/codeql.yml) [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=auvents-brave_Stheno&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=auvents-brave_Stheno) [![Coverage](https://sonarcloud.io/api/project_badges/measure?project=auvents-brave_Stheno&metric=coverage)](https://sonarcloud.io/summary/new_code?id=auvents-brave_Stheno)

[![DocC](https://img.shields.io/badge/DocC-available-brightgreen)](https://auvents-brave.github.io/Stheno/)

Documentation is available directly in Xcode and VS Code, and [online](https://auvents-brave.github.io/Stheno/).

## Native bridge

The nested [`Bridge/`](Bridge) package builds **libSthenoBridge**, a dynamic
library exposing Sthenô's unit conversions, display formatting and mDNS
Bonjour discovery through a plain C ABI (`stheno_bridge_*`), so non-Swift
hosts — C# via P/Invoke, Python via ctypes, anything that can load a shared
library — reuse the same code instead of reimplementing it. Build it with
`swift build -c release` from `Bridge/`; every returned string is a
caller-owned UTF-8 buffer released with `stheno_bridge_string_free`.

`stheno_bridge_discover` browses the marine service types by default (Signal
K over HTTP and WebSocket, NMEA 0183, and the Garmin / Navico / Raymarine /
Furuno vendor types) and returns each endpoint with a ready-to-open URL. It
carries the back-end's own limits: Windows needs Apple's Bonjour service and
Linux needs Avahi, and where no back-end exists — Android — the call reports
`ok:false` with the reason rather than pretending the network is empty, so
the host can browse with its own platform API instead.

## Platforms and CI

| Platform | CI Status |
|---|---|
| ![macOS](https://img.shields.io/badge/macOS-111111?logo=apple&logoColor=white) ![min OS 13.0+](https://img.shields.io/badge/min%20OS-13.0%2B-444444) | [![macOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-macos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-macos.yml) |
| ![Mac Catalyst](https://img.shields.io/badge/Mac_Catalyst-111111?logo=apple&logoColor=white) ![min OS 16.0+](https://img.shields.io/badge/min%20OS-16.0%2B-444444) | [![Mac Catalyst](https://github.com/auvents-brave/Stheno/actions/workflows/apple-maccatalyst.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-maccatalyst.yml) |
| ![iOS](https://img.shields.io/badge/iOS-111111?logo=apple&logoColor=white) ![min OS 16.0+](https://img.shields.io/badge/min%20OS-16.0%2B-444444) | [![iOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ios.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ios.yml) |
| ![iPadOS](https://img.shields.io/badge/iPadOS-111111?logo=apple&logoColor=white) ![min OS 16.0+](https://img.shields.io/badge/min%20OS-16.0%2B-444444) | [![iPadOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ipados.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ipados.yml) |
| ![tvOS](https://img.shields.io/badge/tvOS-111111?logo=apple&logoColor=white) ![min OS 16.0+](https://img.shields.io/badge/min%20OS-16.0%2B-444444) | [![tvOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-tvos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-tvos.yml) |
| ![watchOS](https://img.shields.io/badge/watchOS-111111?logo=apple&logoColor=white) ![min OS 9.0+](https://img.shields.io/badge/min%20OS-9.0%2B-444444) | [![watchOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-watchos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-watchos.yml) |
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
- [`Volume`](https://auvents-brave.github.io/Stheno/documentation/stheno/volume/) - Represents a volume (litres, cubic metres, US and imperial gallons) with conversion and formatting helpers — note the two gallons differ (3.785 L vs 4.546 L).
- [`Formatted`](https://auvents-brave.github.io/Stheno/documentation/stheno/formatted/) - A display-ready value/unit pair (e.g. `"12"` / `"kn"`). Every measurement type above exposes a unified `formatted(as:)` taking its own `Format` enum and returning a `Formatted`, so UIs can render the value large and the unit small without re-parsing strings (`Coordinate.formatted(as:)` returns a latitude/longitude string pair instead). `unit` is empty for formats that carry none, such as a cardinal direction.
- [`BeaufortScale`](https://auvents-brave.github.io/Stheno/documentation/stheno/beaufortscale/) and [`CardinalDirection`](https://auvents-brave.github.io/Stheno/documentation/stheno/cardinaldirection/) - Wind-speed force mapping and 16-point compass directions, used by the angle and speed formats.
- [`DistanceUnit`](https://auvents-brave.github.io/Stheno/documentation/stheno/distanceunit/), [`SpeedUnit`](https://auvents-brave.github.io/Stheno/documentation/stheno/speedunit/), [`TemperatureUnit`](https://auvents-brave.github.io/Stheno/documentation/stheno/temperatureunit/) - The unit enumerations behind the conversions. `TemperatureUnit.preferred(for:)` and `VolumeUnit.preferred(for:)` resolve the unit the user expects for a locale — honouring the device-level settings on Apple platforms; the temperature setting is independent of both the region and the measurement system (a metric device can read °F, and vice versa).


### Geolocation

- [`Geo`](https://auvents-brave.github.io/Stheno/documentation/stheno/geo/) - Utility functions for geographic calculations (great-circle distance, bearings, etc.).

### Network

#### Service discovery (mDNS / Bonjour)

[`BonjourDiscovery`](https://auvents-brave.github.io/Stheno/documentation/stheno/bonjourdiscovery/) browses the local network for mDNS/Bonjour services and yields fully resolved endpoints (host, port, path) as an `AsyncThrowingStream`. A single cross-platform API is implemented on top of the native back-end of each OS:

| Platform | Back-end | Notes |
|---|---|---|
| iOS / macOS / tvOS / watchOS / visionOS / Mac Catalyst | `NWBrowser` (Network.framework) | No extra dependency. |
| Linux | Avahi via the `dns_sd` compatibility C API | Requires `libavahi-compat-libdnssd-dev` at runtime; library probed via `dlopen` so binaries launch even when it is absent. |
| Windows | `DnsServiceBrowse` / `DnsServiceResolve` (`windns.h`) | Windows 10 1709 and later — no third-party install. |

- [`BonjourDiscovery`](https://auvents-brave.github.io/Stheno/documentation/stheno/bonjourdiscovery/) - Browses mDNS service types with a configurable timeout.
- [`DiscoveredEndpoint`](https://auvents-brave.github.io/Stheno/documentation/stheno/discoveredendpoint/) - Resolved service: scheme, host, port, path, label and a ready-to-use connection `url`.
- [`BonjourServiceEntry`](https://auvents-brave.github.io/Stheno/documentation/stheno/bonjourserviceentry/) - Declares a service type to look for (mDNS PTR string, URL scheme, default path, display label).
- [`bonjourDefaultServiceTypes`](https://auvents-brave.github.io/Stheno/documentation/stheno/bonjourdefaultservicetypes) - Built-in service catalogue covering marine (Signal K, NMEA 0183, vendor MFDs), file sharing (SMB, AFP, SFTP, FTP, NFS, WebDAV), printing (IPP, LPR), multimedia (AirPlay, Chromecast, DAAP), remote access (SSH, VNC, RDP) and web/IoT (HTTP/S, HomeKit, MQTT).
- [`BonjourDiscoveryError`](https://auvents-brave.github.io/Stheno/documentation/stheno/bonjourdiscoveryerror/) - Surfaces back-end failures (e.g. Avahi missing on Linux).

Example — browse the local network for 5 s and connect to the first Signal K server found:
```swift
let discovery = BonjourDiscovery()
for try await endpoint in discovery.browse(timeout: 5) {
    print(endpoint)                  // "[signalk-http] raspberrypi — http://192.168.1.20:3000/signalk"
    if endpoint.label == "signalk-http" {
        // Connect to endpoint.url …
        break
    }
}
```

The stream finishes automatically at the timeout, can be discarded early (`break`), and cleans up its underlying browsers/resolvers via `onTermination`. Pass your own `serviceTypes:` array to browse non-default services.

#### DNS resolution

- [`DomainResolver`](https://auvents-brave.github.io/Stheno/documentation/stheno/domainresolver/) - Resolves a hostname to its IP addresses using the system resolver (`getaddrinfo`). `resolve(_:)` returns every address; `resolveIPv4(_:)` / `resolveIPv6(_:)` return the first match of a given family, and a `ResolveError` surfaces lookup failures. (Apple platforms, Linux and Windows; not available on Android or WASI.)

```swift
let addresses = try await DomainResolver.resolve("example.com")
// ["93.184.216.34", "2606:2800:21f:cb07:6820:80da:af6b:8b2c"]
```

#### HTTP

- [`downloadURLasString`](https://auvents-brave.github.io/Stheno/documentation/stheno/downloadurlasstring(from:completion:)) - Downloads the contents of the given URL and decodes it as a UTF-8 `String`. (Not implemented on WASI)
> Uses only the pure toolchain, not [SwiftNIO](https://github.com/apple/swift-nio), even on Linux or Windows.

### Colors

- [`Color`](https://auvents-brave.github.io/Stheno/documentation/stheno/color/) - Cross-platform color support with strict HTML hex parsing/formatting and native bridging (`Color`, `UIColor`, `NSColor`) when available.

### HTML

- [`cleanHtml(from:)`](https://auvents-brave.github.io/Stheno/documentation/stheno/cleanhtml(from:))  - Removes all known HTML tags from a string and decodes common HTML character entities to their Unicode equivalents.

Example:
```swift
let result = cleanHtml(from: "<body><h1>Un &oelig;il &eacute;veill&eacute;</h1>&amp; exemple &agrave;  &lt;10&euro;&gt;</body>")
print(result)
```
Output:
```
Un œil éveillé & exemple à <10€>
```

### Misc Utilities

- Extension to [`Bundle`](https://auvents-brave.github.io/Stheno/documentation/stheno/foundation/bundle) to access versioning information and bundle name from the app’s Info.plist.

- `isRunningInPreviews` - Indicates whether code is running under Xcode previews.

- `isTestFlight` - Indicates whether the app is running a TestFlight build (a sandbox App Store receipt).

- [`Throttled`](https://auvents-brave.github.io/Stheno/documentation/stheno/throttled/) - A property wrapper that throttles updates to its wrapped value.

- [`interceptingStdOut(to:encoding:body:)`](https://auvents-brave.github.io/Stheno/documentation/stheno/interceptingstdout(to:encoding:body:)) - Captures text written to standard output into a `TextOutputStream` while a closure runs (Apple platforms only).


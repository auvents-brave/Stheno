# Sthenô

> Note
>
> **Sthenô** (Σθεννώ), another of the three Gorgon sisters in Greek mythology and sister to **Euryale** and **Medusa**, is traditionally depicted as immortal. Her name conveys “strength” or “might,” underscoring themes of endurance and power. This reference aligns with the library’s focus on robust, reusable components.


Sthenô is a small, cross-platform Swift package that consolidates reusable, context-independent components. It focuses on well-scoped building blocks with clear APIs, thorough DocC documentation, and solid unit test coverage, designed to be adopted piecemeal across apps, frameworks, and tools.

Sthenô depends only on [swift-log](https://github.com/apple/swift-log) for structured logging, ensuring consistent and configurable diagnostics across platforms while keeping the overall dependency footprint minimal.

Continuous Integration (CI) is handled through GitHub Actions, which automatically builds, tests, and analyzes the codebase using CodeQL to ensure quality, consistency, and cross-platform reliability.

![Swift](https://img.shields.io/badge/Swift-6.2-orange?logo=swift)

[![CodeQL](https://github.com/auvents-brave/Stheno/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/auvents-brave/Stheno/actions/workflows/github-code-scanning/codeql)

[![DocC](https://img.shields.io/badge/docs-available-brightgreen)](https://auvents-brave.github.io/Stheno/)

## CI Status

| Platform | Status |
|---|---|
| ![macOS](https://img.shields.io/badge/platform-macOS-000000?logo=apple) **macOS** (`10.13` -> `26.2`) | [![Apple macOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-macos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-macos.yml) |
| ![Mac Catalyst](https://img.shields.io/badge/platform-Mac_Catalyst-1C1C1E?logo=apple) **Mac Catalyst** (`13.0` -> `26.2`) | [![Apple Mac Catalyst](https://github.com/auvents-brave/Stheno/actions/workflows/apple-maccatalyst.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-maccatalyst.yml) |
| ![iOS](https://img.shields.io/badge/platform-iOS-0A84FF?logo=apple) **iOS (iPhone)** (`12.0` -> `26.2`) | [![Apple iOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ios.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ios.yml) |
| ![iPadOS](https://img.shields.io/badge/platform-iPadOS-0A84FF?logo=apple) **iPad** (`12.0` -> `26.2`) | [![Apple iPad](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ipad.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-ipad.yml) |
| ![tvOS](https://img.shields.io/badge/platform-tvOS-1C1C1E?logo=apple) **tvOS** (`12.0` -> `26.2`) | [![Apple tvOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-tvos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-tvos.yml) |
| ![watchOS](https://img.shields.io/badge/platform-watchOS-1C1C1E?logo=apple) **watchOS** (`5.0` -> `26.2`) | [![Apple watchOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-watchos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-watchos.yml) |
| ![visionOS](https://img.shields.io/badge/platform-visionOS-5E5CE6?logo=apple) **visionOS** (`1.0` -> `26.2`) | [![Apple visionOS](https://github.com/auvents-brave/Stheno/actions/workflows/apple-visionos.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/apple-visionos.yml) |
| ![Linux](https://img.shields.io/badge/platform-Linux_(WASI)-FCC624?logo=linux&logoColor=black) **Linux** (`ubuntu-24.04`) | [![Linux](https://github.com/auvents-brave/Stheno/actions/workflows/linux.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/linux.yml) |
| ![Windows](https://img.shields.io/badge/platform-Windows-0078D6?logo=windows) **Windows** (`windows-2025`) | [![Windows](https://github.com/auvents-brave/Stheno/actions/workflows/windows.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/windows.yml) |
| ![WebAssembly](https://img.shields.io/badge/platform-WebAssembly-654FF0?logo=webassembly) **WebAssembly** (`wasm32-unknown-wasi` on Ubuntu latest) | [![WebAssembly](https://github.com/auvents-brave/Stheno/actions/workflows/wasm.yml/badge.svg?branch=main)](https://github.com/auvents-brave/Stheno/actions/workflows/wasm.yml) |

## Library Contents

### Development

#### Locale Testing

The package includes cross-platform locale configuration support, particularly important for server-side Swift applications. To verify locale settings:

```bash
# Build the locale test image
docker build -f Dockerfile.locale -t stheno:locale .

# Run locale tests
docker run --rm stheno:locale .build/debug/SthenoTool locale-test
```

The tests verify:
- Proper locale environment configuration (fr_FR.UTF-8)
- Number formatting (e.g., "1 234,56")
- Date formatting in French
- Timezone settings (Europe/Paris)

This is automatically tested in CI for each PR and push to main. See the [locale test workflow](.github/workflows/locale-test.yml) for details.

## Library Contents
```

Sthenô brings together a set of focused components spanning system utilities, user interface helpers, and geospatial tools. It includes support for cloud-synced preferences, HTML and date processing.
The library also offers lightweight WebKit and MapKit abstractions, and convenience views for embedding web content. Geometry and coordinate types with bearing and great-circle distance calculations for accurate geodesic measurements. Its geospatial capabilities include WMTS Tile Overlay support with local caching for efficient and offline-ready visualization and reverse geocoding utilities to convert coordinates into meaningful human-readable locations.
In addition, Sthenô integrates lightweight image classification tools for context-aware visual recognition tasks.

All modules are written in pure Swift, designed for reuse across Apple platforms, Linux, Windows, and WebAssembly.

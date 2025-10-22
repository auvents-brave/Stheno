# Sthenô

> Note
>
> **Sthenô** (Σθεννώ), another of the three Gorgon sisters in Greek mythology and sister to **Euryale** and **Medusa**, is traditionally depicted as immortal. Her name conveys “strength” or “might,” underscoring themes of endurance and power. This reference aligns with the library’s focus on robust, reusable components.


Sthenô is a small, cross-platform Swift package that consolidates reusable, context-independent components. It focuses on well-scoped building blocks with clear APIs, thorough DocC documentation, and solid unit test coverage, designed to be adopted piecemeal across apps, frameworks, and tools.

Sthenô depends only on [swift-log](https://github.com/apple/swift-log) for structured logging, ensuring consistent and configurable diagnostics across platforms while keeping the overall dependency footprint minimal.

Continuous Integration (CI) is handled through GitHub Actions, which automatically builds, tests, and analyzes the codebase using CodeQL to ensure quality, consistency, and cross-platform reliability.

[![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20macCatalyst%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20visionOS%20%7C%20Linux%20%7C%20Windows%20%7C%20WebAssembly-lightgrey)]()
![Swift](https://img.shields.io/badge/Swift-6.2-orange?logo=swift)
[![CI](https://github.com/auvents-brave/Stheno/actions/workflows/build.yml/badge.svg)](https://github.com/auvents-brave/Stheno/actions/workflows/build.yml)
[![CodeQL](https://github.com/auvents-brave/Stheno/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/auvents-brave/Stheno/actions/workflows/github-code-scanning/codeql)
[![DocC](https://img.shields.io/badge/docs-available-brightgreen)](https://auvents-brave.github.io/Stheno/)

## Library Contents

Sthenô brings together a set of focused components spanning system utilities, user interface helpers, and geospatial tools. It includes support for cloud-synced preferences, HTML and date processing.
The library also offers lightweight WebKit and MapKit abstractions, and convenience views for embedding web content. Geometry and coordinate types with bearing and great-circle distance calculations for accurate geodesic measurements. Its geospatial capabilities include WMTS Tile Overlay support with local caching for efficient and offline-ready visualization and reverse geocoding utilities to convert coordinates into meaningful human-readable locations.
In addition, Sthenô integrates lightweight image classification tools for context-aware visual recognition tasks.

All modules are written in pure Swift, designed for reuse across Apple platforms, Linux, Windows, and WebAssembly.

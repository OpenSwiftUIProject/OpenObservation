# OpenObservation

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenSwiftUIProject%2FOpenObservation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/OpenSwiftUIProject/OpenObservation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenSwiftUIProject%2FOpenObservation%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/OpenSwiftUIProject/OpenObservation)

Backport implementation of Swift's Observation framework with access to `@_spi(SwiftUI)` APIs.

| **CI Status** |
|---|
|[![macOS](https://github.com/OpenSwiftUIProject/OpenObservation/actions/workflows/macos.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenObservation/actions/workflows/macos.yml)|
|[![Ubuntu](https://github.com/OpenSwiftUIProject/OpenObservation/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenObservation/actions/workflows/ubuntu.yml)|

## Purpose

The official Observation framework in Swift Toolchain doesn't ship with `package.swiftinterface`, preventing direct use of `@_spi(SwiftUI)` APIs. There are two solutions to this problem, but this project provides solution 2:

1. **Manual workaround** (not included): Construct a `package.swiftinterface` and add it to the toolchain (⚠️ No API stability, may break between toolchain versions)

2. **OpenObservation approach** (this project): Reimplement Observation framework, allowing OpenSwiftUI to import it via `@_spi(OpenSwiftUI)`

## Features

- Full Observation framework implementation
- Cross-platform support (macOS, iOS, tvOS, watchOS)
- `@Observable` macro support
- Thread-safe tracking
- Pure Swift fallback for platforms without toolchain support

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/OpenSwiftUIProject/OpenObservation", from: "1.0.0")
]
```

## Usage

```swift
import OpenObservation

@Observable
class Counter {
    var value: Int = 0
    
    func increment() {
        value += 1
    }
}

// Use with ObservationTracking
let counter = Counter()
withObservationTracking {
    print("Counter value: \(counter.value)")
} onChange: {
    print("Counter changed!")
}
```

## Configuration

- `OPENOBSERVATION_SWIFT_TOOLCHAIN_SUPPORTED`: Enable Swift toolchain runtime implementation (auto-detected)
    - Config `OPENOBSERVATION_SWIFT_TOOLCHAIN_PATH` and `OPENOBSERVATION_SWIFT_TOOLCHAIN_VERSION`
- `OPENOBSERVATION_DEVELOPMENT`: Development mode

## License

- **OpenObservation code**: MIT License
- **Code derived from Swift project**: Apache License v2.0 with Runtime Library Exception
# ``OpenObservation``

A backport implementation of Swift's Observation framework with access to @_spi(SwiftUI) APIs.

## Overview

OpenObservation provides a powerful, type-safe mechanism for observing changes to properties in Swift objects. It's designed to overcome the limitations of traditional observation patterns like KVO and Combine, offering fine-grained property tracking with minimal boilerplate.

This framework is particularly useful when:
- Building reactive UI frameworks
- Implementing data binding patterns
- Creating observable view models
- Porting SwiftUI code to non-Apple platforms

## Topics

### Essentials

- ``Observable``
- ``ObservationRegistrar``
- <doc:GettingStarted>

### Observation Tracking

- ``withObservationTracking(_:onChange:)``
- ``ObservationTracking``

### Advanced Usage

- <doc:HowObservationWorks>
- <doc:PerformanceConsiderations>

### Macros

- ``Observable()``
- ``ObservationTracked()``
- ``ObservationIgnored()``
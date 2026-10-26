# Using module selectors with OpenObservation

You normally do not need module selectors when using OpenObservation. If only
OpenObservation's macros are visible in a source file, use their plain names:

```swift
import OpenObservation

@Observable
final class CounterModel {
    var count = 0
    @ObservationIgnored var step = 1

    func increment() {
        count += step
    }
}
```

## When names become ambiguous

OpenObservation and Apple's Observation module both define `Observable`,
`ObservationTracked`, and `ObservationIgnored`. If the same source file also
imports Observation, the compiler cannot choose between these macros by name.
This can produce an `Ambiguous use of 'Observable()'` diagnostic.

Observation can also be imported indirectly. Foundation re-exports it, and
UIKit and AppKit import Foundation. Importing these frameworks can therefore
introduce the same conflict without an explicit `import Observation` statement.
Other modules that re-export these frameworks can introduce the conflict too.

## Select the OpenObservation macros explicitly

OpenObservation requires a Swift 6.3 or later compiler, which supports module
selectors ([SE-0491](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0491-module-selectors.md)).
Add the `OpenObservation::` module selector to each OpenObservation macro you
write in a file where both modules are visible:

```swift
import AppKit
import OpenObservation

@OpenObservation::Observable
final class CounterModel {
    var count = 0
    @OpenObservation::ObservationIgnored var step = 1

    func increment() {
        count += step
    }
}
```

For an iOS file, replace `import AppKit` with `import UIKit`. Use the same
selectors if the file imports Observation directly. The `::` syntax selects
the declaration from the named module.

You normally do not write `ObservationTracked` yourself; `Observable` adds it
to stored properties. If you use it explicitly, write
`@OpenObservation::ObservationTracked` in files with this conflict.

## Generated attributes must also select the module

Qualifying only the attributes in your source is not enough. Macro-generated
code is resolved in the source file's import context, so an unqualified
generated attribute can still be ambiguous.

OpenObservation's macro implementation therefore always emits
`@OpenObservation::ObservationTracked` and
`@OpenObservation::ObservationIgnored`. This includes the attributes on tracked
properties, the observation registrar, and backing storage. The implementation
also recognizes qualified attributes, so a property marked with
`@OpenObservation::ObservationIgnored` remains excluded from tracking.

These internal selectors do not require you to qualify macros in files where
their names are unambiguous.

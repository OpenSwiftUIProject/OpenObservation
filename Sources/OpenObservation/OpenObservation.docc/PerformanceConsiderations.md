# Performance Considerations

Optimize your use of the Observation framework for maximum performance.

## Overview

While the Observation framework is designed to be highly efficient, understanding its performance characteristics helps you write optimal code. This guide covers key performance considerations and best practices.

## Key Performance Features

### Fine-Grained Tracking

The framework only observes properties that are actually accessed:

```swift
@Observable
class LargeModel {
    var property1 = "a"
    var property2 = "b"
    var property3 = "c"
    // ... 100 more properties
    
    var property104 = "z"
}

let model = LargeModel()

withObservationTracking {
    // Only property1 and property3 are tracked
    print(model.property1)
    print(model.property3)
} onChange: {
    // Only fires when property1 or property3 change
    // No overhead for the other 102 properties!
}
```

### Lazy Registration

Observers are registered lazily after property access:

```swift
withObservationTracking {
    if condition {
        print(model.expensiveProperty)  // Only tracked if condition is true
    }
} onChange: {
    // Observer only registered if condition was true
}
```

### Coalesced Updates

Multiple property changes trigger a single onChange:

```swift
withObservationTracking {
    print(model.firstName)
    print(model.lastName)
} onChange: {
    // Fires once even if both properties change
    updateUI()
}

// Both changes trigger only one onChange
model.firstName = "John"
model.lastName = "Doe"
```

## Performance Best Practices

### 1. Minimize Tracking Scope

Only track properties you actually need:

```swift
// Inefficient: Tracking everything
withObservationTracking {
    let user = model.currentUser
    print(user.name)
    print(user.email)
    print(user.profile)
    print(user.settings)
    print(user.preferences)
} onChange: { }

// Efficient: Track only what you use
withObservationTracking {
    print(model.currentUser.name)  // Only track name
} onChange: { }
```

### 2. Avoid Computed Property Chains

Long chains of computed properties can impact performance:

```swift
@Observable
class InefficientModel {
    var base = 1
    
    // Avoid: Deep computed property chains
    var level1: Int { base * 2 }
    var level2: Int { level1 * 2 }
    var level3: Int { level2 * 2 }
    var level4: Int { level3 * 2 }  // Recalculates entire chain
}

@Observable  
class EfficientModel {
    var base = 1
    
    // Better: Cache intermediate values if needed
    private var _cachedResult: Int?
    
    var result: Int {
        if let cached = _cachedResult {
            return cached
        }
        let computed = base * 16  // Direct calculation
        _cachedResult = computed
        return computed
    }
    
    func invalidateCache() {
        _cachedResult = nil
    }
}
```

### 3. Use @ObservationIgnored for Cache

Mark cache and temporary properties as ignored:

```swift
@Observable
class DataModel {
    var sourceData: [Item] = []
    
    @ObservationIgnored
    private var _filteredCache: [Item]?
    
    @ObservationIgnored
    private var _sortedCache: [Item]?
    
    var filteredItems: [Item] {
        if let cached = _filteredCache {
            return cached
        }
        let filtered = sourceData.filter { $0.isActive }
        _filteredCache = filtered
        return filtered
    }
    
    // Clear cache when source changes
    private func dataDidChange() {
        _filteredCache = nil
        _sortedCache = nil
    }
}
```

### 4. Batch Updates

Group related changes together:

```swift
@Observable
class BatchUpdateModel {
    var items: [String] = []
    var count = 0
    var lastUpdated: Date?
    
    // Inefficient: Multiple separate updates
    func inefficientAdd(_ item: String) {
        items.append(item)  // Trigger 1
        count += 1          // Trigger 2
        lastUpdated = Date() // Trigger 3
    }
    
    // Efficient: Batch updates
    func efficientAdd(_ items: [String]) {
        self.items.append(contentsOf: items)
        self.count = self.items.count
        self.lastUpdated = Date()
        // All changes trigger once
    }
}
```

### 5. Avoid Observation in Tight Loops

Don't create observations inside performance-critical loops:

```swift
// Inefficient: Creating observations in a loop
for item in largeArray {
    withObservationTracking {
        process(item.value)
    } onChange: {
        handleChange(item)
    }
}

// Efficient: Single observation for all items
withObservationTracking {
    for item in largeArray {
        process(item.value)
    }
} onChange: {
    handleBatchChange()
}
```

## Memory Considerations

### Weak References in Closures

Prevent retain cycles with weak references:

```swift
class ViewController {
    let model = MyModel()
    
    func setupObservation() {
        withObservationTracking {
            print(model.value)
        } onChange: { [weak self] in
            self?.updateUI()  // Weak reference prevents retain cycle
        }
    }
}
```

### Observation Cleanup

Observations are automatically cleaned up, but you can help:

```swift
class LongLivedController {
    var activeObservations: [ObservationTracking] = []
    
    func startObserving() {
        let tracking = ObservationTracking(nil)
        // ... setup tracking
        activeObservations.append(tracking)
    }
    
    func cleanup() {
        // Explicitly cancel all observations
        activeObservations.forEach { $0.cancel() }
        activeObservations.removeAll()
    }
    
    deinit {
        cleanup()
    }
}
```

## Benchmarking

### Measuring Performance

Use Instruments and benchmarks to measure performance:

```swift
import XCTest

class ObservationBenchmarks: XCTestCase {
    func testObservationOverhead() {
        let model = LargeModel()
        
        measure {
            withObservationTracking {
                // Access multiple properties
                _ = model.property1
                _ = model.property2
                _ = model.property3
            } onChange: { }
        }
    }
    
    func testBatchUpdatePerformance() {
        let model = BatchModel()
        let items = (0..<1000).map { "Item \($0)" }
        
        measure {
            model.batchUpdate(items)
        }
    }
}
```

### Performance Metrics

Typical performance characteristics:

| Operation | Time Complexity | Space Complexity |
|-----------|----------------|------------------|
| Property Access | O(1) | O(1) |
| Observer Registration | O(n) | O(n) |
| Change Notification | O(m) | O(1) |
| Observer Cleanup | O(n) | O(1) |

Where:
- n = number of tracked properties
- m = number of registered observers

## Platform-Specific Optimizations

### Swift Toolchain Support

When available, use native toolchain support:

```swift
#if OPENOBSERVATION_SWIFT_TOOLCHAIN_SUPPORTED
// Uses optimized C++ implementation
#else
// Falls back to pure Swift implementation
#endif
```

### Compiler Optimizations

Enable optimizations in release builds:

```swift
// Package.swift
.target(
    name: "YourApp",
    dependencies: ["OpenObservation"],
    swiftSettings: [
        .unsafeFlags(["-O"], .when(configuration: .release))
    ]
)
```

## Common Performance Pitfalls

### 1. Observing in View Drawing

Avoid creating observations during view drawing:

```swift
// Bad: Creating observation in draw
override func draw(_ rect: CGRect) {
    withObservationTracking {
        drawContent(model.data)
    } onChange: {
        setNeedsDisplay()  // Can cause infinite loop!
    }
}

// Good: Setup observation once
override func viewDidLoad() {
    withObservationTracking {
        _ = model.data
    } onChange: { [weak self] in
        self?.setNeedsDisplay()
    }
}
```

### 2. Excessive Granularity

Balance between granularity and performance:

```swift
// Too granular: Observing individual characters
@Observable
class CharacterModel {
    var char1 = "a"
    var char2 = "b"
    var char3 = "c"
    // ... 100 more properties
}

// Better: Group related data
@Observable
class TextModel {
    var text = "abc..."  // Single property for text
    var metadata: TextMetadata  // Group related properties
}
```

### 3. Recursive Observations

Avoid observations that trigger themselves:

```swift
@Observable
class RecursiveModel {
    var value = 0
    
    func problematicSetup() {
        withObservationTracking {
            print(value)
        } onChange: { [weak self] in
            self?.value += 1  // Triggers itself!
            self?.problematicSetup()  // Infinite recursion
        }
    }
}
```

## Profiling Tools

### Using Instruments

Profile your app with Instruments:

1. **Time Profiler**: Identify observation-related bottlenecks
2. **Allocations**: Track memory usage of observations
3. **System Trace**: Analyze threading behavior

### Custom Performance Logging

Add performance logging for debugging:

```swift
@Observable
class InstrumentedModel {
    var value = 0 {
        willSet {
            let start = CFAbsoluteTimeGetCurrent()
            defer {
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                if elapsed > 0.001 {  // Log slow updates
                    print("Slow update: \(elapsed)s")
                }
            }
        }
    }
}
```

## Conclusion

The Observation framework is designed for excellent performance out of the box. By following these guidelines:

- Track only necessary properties
- Use @ObservationIgnored for cache
- Batch related updates
- Avoid observation in tight loops
- Profile and measure your specific use cases

You can build highly performant reactive applications that scale efficiently with your data complexity.
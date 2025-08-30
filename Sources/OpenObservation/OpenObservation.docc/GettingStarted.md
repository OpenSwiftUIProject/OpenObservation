# Getting Started

Learn how to use OpenObservation in your Swift projects.

## Overview

OpenObservation provides a powerful observation framework that makes it easy to track changes to properties in your Swift objects. This guide will walk you through the basics of using the framework.

## Installation

### Swift Package Manager

Add OpenObservation to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/OpenSwiftUIProject/OpenObservation", from: "1.0.0")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: ["OpenObservation"]
)
```

## Basic Usage

### Making a Class Observable

Use the `@Observable` macro to make any class observable:

```swift
import OpenObservation

@Observable
class TodoItem {
    var title: String
    var isCompleted: Bool
    var priority: Int
    
    init(title: String, isCompleted: Bool = false, priority: Int = 0) {
        self.title = title
        self.isCompleted = isCompleted
        self.priority = priority
    }
}
```

That's it! All stored properties are now automatically observable.

### Tracking Property Changes

Use `withObservationTracking` to observe changes to specific properties:

```swift
let todo = TodoItem(title: "Learn Observation")

withObservationTracking {
    // Only the properties accessed here will be tracked
    print("Title: \(todo.title)")
    print("Completed: \(todo.isCompleted)")
} onChange: {
    print("Todo item changed!")
}

// Later...
todo.title = "Master Observation"  // Triggers onChange (called once)
todo.isCompleted = true  // Does NOT trigger onChange again
todo.priority = 1  // Does NOT trigger onChange (not tracked)
```

**Important:** The `onChange` closure is called only **once** after the first change to any tracked property. Subsequent changes to tracked properties will not trigger the closure again. To continue observing, you need to re-establish the observation tracking.

## Common Patterns

### View Model Pattern

```swift
@Observable
class TodoListViewModel {
    var todos: [TodoItem] = []
    var filter: FilterOption = .all
    
    var filteredTodos: [TodoItem] {
        switch filter {
        case .all:
            return todos
        case .active:
            return todos.filter { !$0.isCompleted }
        case .completed:
            return todos.filter { $0.isCompleted }
        }
    }
    
    func addTodo(_ title: String) {
        todos.append(TodoItem(title: title))
    }
    
    func toggleTodo(at index: Int) {
        todos[index].isCompleted.toggle()
    }
}

enum FilterOption {
    case all, active, completed
}
```

### Observing Nested Objects

```swift
@Observable
class User {
    var name: String
    var profile: Profile
    
    init(name: String, profile: Profile) {
        self.name = name
        self.profile = profile
    }
}

@Observable
class Profile {
    var bio: String = ""
    var avatarURL: URL?
}

// Usage
let user = User(name: "Alice", profile: Profile())

withObservationTracking {
    print(user.name)
    print(user.profile.bio)  // Tracks both user.profile AND profile.bio
} onChange: {
    print("User or profile changed")  // Called once on first change
}

// First change triggers onChange
user.name = "Bob"  // Triggers onChange
// Subsequent changes don't trigger
user.profile.bio = "New bio"  // Does NOT trigger onChange again
```

### Ignoring Properties

Use `@ObservationIgnored` to exclude properties from observation:

```swift
@Observable
class DataModel {
    var publicData: String = "visible"
    
    @ObservationIgnored
    var internalCache: [String: Any] = [:]  // Never triggers observations
    
    @ObservationIgnored
    var debugInfo: String = ""  // Not tracked
}
```

## Advanced Usage

### Custom Observation Tracking

For more control, you can use the lower-level APIs:

```swift
@Observable
class CustomModel {
    var value: Int = 0
    
    func startTracking() {
        withObservationTracking {
            _ = self.value
        } onChange: { [weak self] in
            self?.handleChange()
        }
    }
    
    private func handleChange() {
        print("Value changed to: \(value)")
        // Re-establish observation
        startTracking()
    }
}
```

### Conditional Tracking

Track different properties based on state:

```swift
@Observable
class ConditionalModel {
    var useAdvancedMode = false
    var basicValue = 0
    var advancedValue = 0
    
    func setupObservation() {
        withObservationTracking {
            if useAdvancedMode {
                print("Advanced: \(advancedValue)")
            } else {
                print("Basic: \(basicValue)")
            }
        } onChange: {
            print("Relevant value changed")
            self.setupObservation()  // Re-establish with new conditions
        }
    }
}
```

### Working with One-Shot Observations

Since `onChange` is called only once, you may need to re-establish observations:

```swift
@Observable
class RepeatingObserver {
    var value: Int = 0
    
    func observeContinuously() {
        withObservationTracking {
            print("Current value: \(value)")
        } onChange: { [weak self] in
            print("Value changed!")
            // Re-establish observation for next change
            self?.observeContinuously()
        }
    }
}

## Best Practices

### 1. Keep Observable Classes Focused

Observable classes should have a single responsibility:

```swift
// Good: Focused responsibility
@Observable
class UserSettings {
    var theme: Theme
    var notifications: Bool
    var language: String
}

// Avoid: Too many responsibilities
@Observable
class AppState {
    var user: User
    var settings: Settings
    var network: NetworkStatus
    var cache: Cache
    // Too much in one class!
}
```

### 2. Use Computed Properties Wisely

Computed properties in observable classes are recalculated when dependencies change:

```swift
@Observable
class ShoppingCart {
    var items: [CartItem] = []
    
    // Good: Simple computed property
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }
    
    // Avoid: Heavy computation in computed properties
    var complexAnalysis: Analysis {
        // Don't do expensive operations here
        performExpensiveAnalysis(items)
    }
}
```

### 3. Avoid Observation Loops

Be careful not to create infinite observation loops:

```swift
@Observable
class LoopModel {
    var value1: Int = 0 {
        didSet {
            // Avoid: This could create a loop
            // value2 = value1 * 2
        }
    }
    var value2: Int = 0
    
    // Better: Use methods for derived updates
    func updateValue2() {
        value2 = value1 * 2
    }
}
```

### 4. Clean Up Observations

While observations are automatically cleaned up, you can manually cancel them:

```swift
class ViewController {
    var observation: ObservationTracking?
    
    func startObserving() {
        let tracking = ObservationTracking(nil)
        ObservationTracking._installTracking(tracking, willSet: { _ in
            // Handle changes
        })
        observation = tracking
    }
    
    func stopObserving() {
        observation?.cancel()
        observation = nil
    }
}
```

## Troubleshooting

### Properties Not Being Observed

Make sure you're accessing the property within the tracking closure:

```swift
// Wrong: Property accessed outside tracking
let title = todo.title
withObservationTracking {
    print(title)  // Not tracking todo.title!
} onChange: { }

// Correct: Property accessed inside tracking
withObservationTracking {
    print(todo.title)  // Now tracking todo.title
} onChange: { }
```

### onChange Not Firing

Remember that `onChange` is called only once. Common issues:

1. **One-shot behavior**: The `onChange` closure fires only once after the first change:

```swift
withObservationTracking {
    print(model.value)
} onChange: {
    print("Changed!")  // Only called once
}

model.value = 1  // Triggers onChange
model.value = 2  // Does NOT trigger onChange again
```

2. **Object retention**: Ensure the observed object is retained:

```swift
// Wrong: Object might be deallocated
func setupObservation() {
    let model = MyModel()  // Local variable
    withObservationTracking {
        print(model.value)
    } onChange: {
        // Might never fire if model is deallocated
    }
}

// Correct: Keep a strong reference
class Controller {
    let model = MyModel()  // Instance variable
    
    func setupObservation() {
        withObservationTracking {
            print(model.value)
        } onChange: {
            // Will fire once when model.value changes
            self.setupObservation()  // Re-establish for continuous observation
        }
    }
}
```

## Next Steps

Now that you understand the basics of OpenObservation:

- Read <doc:HowObservationWorks> for a deep dive into the internals
- Check <doc:PerformanceConsiderations> for optimization tips
- Explore the API documentation for ``Observable`` and ``ObservationRegistrar``
- Look at example projects in the GitHub repository
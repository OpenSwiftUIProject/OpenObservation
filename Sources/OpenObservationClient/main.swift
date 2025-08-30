//
//  main.swift
//  OpenObservation
//
//  Created by Kyle on 2025/8/30.
//

import OpenObservation

// MARK: - Basic Observable Classes

@Observable
class Person {
    var name = "Alice"
    var age = 30
    
    @ObservationIgnored
    var internalCounter = 0
}

@Observable
class Model {
    var firstName: String = "First"
    var lastName: String = "Last"
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - Nested Observable Example

@Observable
class ShoppingCart {
    var items: [CartItem] = []
    var discount: Double = 0.0
    
    var total: Double {
        let subtotal = items.reduce(0) { $0 + $1.price * Double($1.quantity) }
        return subtotal * (1 - discount)
    }
    
    func addItem(_ item: CartItem) {
        items.append(item)
    }
}

@Observable
class CartItem {
    var name: String
    var price: Double
    var quantity: Int = 1
    
    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }
}

// MARK: - Example Usage

print("=== Basic Observation Example ===")
let person = Person()

withObservationTracking {
    print("Person: \(person.name), Age: \(person.age)")
} onChange: {
    print("Person data changed! (onChange called once)")
}

// Note: onChange is called only ONCE after the first property change
person.name = "Bob"  // This triggers onChange
person.age = 35      // This does NOT trigger onChange again
// internalCounter won't trigger onChange due to @ObservationIgnored
person.internalCounter = 10

print("\n=== Model with Computed Property ===")
let model = Model()

let result = withObservationTracking {
    print("Full name: \(model.fullName)")
    return model.fullName.count
} onChange: {
    print("Model properties changed! (onChange called once)")
}

print("Initial full name length: \(result)")

// Only the first property change triggers onChange
model.firstName = "John"  // This triggers onChange
model.lastName = "Doe"     // This does NOT trigger onChange again

print("\n=== Shopping Cart Example ===")
let cart = ShoppingCart()

withObservationTracking {
    print("Cart total: $\(cart.total)")
    print("Items count: \(cart.items.count)")
} onChange: {
    print("Cart updated! (onChange called once)")
}

// Only the first change triggers onChange
cart.addItem(CartItem(name: "Coffee", price: 4.99))  // This triggers onChange
cart.addItem(CartItem(name: "Sandwich", price: 8.99))  // This does NOT trigger onChange again
cart.discount = 0.1  // This does NOT trigger onChange again

print("\n=== Selective Property Observation ===")
let anotherPerson = Person()

// Only observe the name property
withObservationTracking {
    print("Observing only name: \(anotherPerson.name)")
} onChange: {
    print("Name changed! (onChange called once)")
}

anotherPerson.name = "Charlie"  // This triggers onChange
anotherPerson.age = 25  // This doesn't trigger onChange (age wasn't accessed)

print("\n=== Multiple Observation Tracking ===")
let person2 = Person()

// Setting up first observation
withObservationTracking {
    print("First observation - Name: \(person2.name)")
} onChange: {
    print("First onChange triggered")
}

// Setting up second observation
withObservationTracking {
    print("Second observation - Age: \(person2.age)")
} onChange: {
    print("Second onChange triggered")
}

person2.name = "David"  // Triggers first onChange
person2.age = 40  // Triggers second onChange

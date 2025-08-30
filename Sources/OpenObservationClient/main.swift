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
    print("Person data changed!")
}

// Trigger the onChange callback
person.name = "Bob"
person.age = 35
// Note: internalCounter won't trigger onChange due to @ObservationIgnored
person.internalCounter = 10

print("\n=== Model with Computed Property ===")
let model = Model()

let result = withObservationTracking {
    print("Full name: \(model.fullName)")
    return model.fullName.count
} onChange: {
    print("Model properties changed, updating UI...")
}

print("Initial full name length: \(result)")

// Changing either property triggers onChange once
model.firstName = "John"
model.lastName = "Doe"

print("\n=== Shopping Cart Example ===")
let cart = ShoppingCart()

withObservationTracking {
    print("Cart total: $\(cart.total)")
    print("Items count: \(cart.items.count)")
} onChange: {
    print("Cart updated! Recalculating total...")
}

// Add items to cart
cart.addItem(CartItem(name: "Coffee", price: 4.99))
cart.addItem(CartItem(name: "Sandwich", price: 8.99))
cart.discount = 0.1 // 10% discount

print("\n=== Selective Property Observation ===")
let anotherPerson = Person()

// Only observe the name property
withObservationTracking {
    print("Observing only name: \(anotherPerson.name)")
} onChange: {
    print("Name changed!")
}

anotherPerson.name = "Charlie" // Triggers onChange
anotherPerson.age = 25 // Doesn't trigger onChange since age wasn't accessed

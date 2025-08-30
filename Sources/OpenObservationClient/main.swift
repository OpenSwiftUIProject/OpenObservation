//
//  main.swift
//  OpenObservation
//
//  Created by Kyle on 2025/8/30.
//

import OpenObservation

@Observable
class A {
    var name = "Alice"
}

let a = A()
a.access(keyPath: \.name)
print(a.name)
a.withMutation(keyPath: \.name) {
    a.name = "Bob"
}
print(a.name)

//
//  OpenObservationMacroTests.swift
//  OpenObservationTests
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(OpenObservationMacros)
import OpenObservationMacros

let testMacros: [String: Macro.Type] = [
    "Observable": ObservableMacro.self,
    "ObservationTracked": ObservationTrackedMacro.self,
    "ObservationIgnored": ObservationIgnoredMacro.self,
]

#endif

final class OpenObservationMacroTests: XCTestCase {
    func testBasicObservable() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            class Model {}
            """,
            expandedSource: """
            class Model {

                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Model, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Model, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableWithProperties() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            class Model {
                var name: String = "John"
                var age: Int = 30
            }
            """,
            expandedSource: """
            class Model {
                var name: String {
                    @storageRestrictions(initializes: _name)
                    init(initialValue) {
                        _name = initialValue
                    }
                    get {
                        access(keyPath: \\.name)
                        return _name
                    }
                    set {
                        withMutation(keyPath: \\.name) {
                            _name = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.name)
                        _$observationRegistrar.willSet(self, keyPath: \\.name)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.name)
                        }
                        yield &_name
                    }
                }
                var age: Int {
                    @storageRestrictions(initializes: _age)
                    init(initialValue) {
                        _age = initialValue
                    }
                    get {
                        access(keyPath: \\.age)
                        return _age
                    }
                    set {
                        withMutation(keyPath: \\.age) {
                            _age = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.age)
                        _$observationRegistrar.willSet(self, keyPath: \\.age)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.age)
                        }
                        yield &_age
                    }
                }

                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Model, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Model, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservationIgnored() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            class Model {
                var tracked: String = "tracked"
                @ObservationIgnored var ignored: Int = 42
            }
            """,
            expandedSource: """
            class Model {
                var tracked: String {
                    @storageRestrictions(initializes: _tracked)
                    init(initialValue) {
                        _tracked = initialValue
                    }
                    get {
                        access(keyPath: \\.tracked)
                        return _tracked
                    }
                    set {
                        withMutation(keyPath: \\.tracked) {
                            _tracked = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.tracked)
                        _$observationRegistrar.willSet(self, keyPath: \\.tracked)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.tracked)
                        }
                        yield &_tracked
                    }
                }
                var ignored: Int = 42

                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Model, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Model, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableWithComputedProperties() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            class Model {
                var stored: String = "stored"
                var computed: String {
                    return stored + " computed"
                }
            }
            """,
            expandedSource: """
            class Model {
                var stored: String {
                    @storageRestrictions(initializes: _stored)
                    init(initialValue) {
                        _stored = initialValue
                    }
                    get {
                        access(keyPath: \\.stored)
                        return _stored
                    }
                    set {
                        withMutation(keyPath: \\.stored) {
                            _stored = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.stored)
                        _$observationRegistrar.willSet(self, keyPath: \\.stored)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.stored)
                        }
                        yield &_stored
                    }
                }
                var computed: String {
                    return stored + " computed"
                }

                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Model, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Model, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableWithExplicitTracked() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            class Model {
                @ObservationTracked var explicit: String = "explicit"
                var implicit: Int = 10
            }
            """,
            expandedSource: """
            class Model {
                var explicit: String {
                    @storageRestrictions(initializes: _explicit)
                    init(initialValue) {
                        _explicit = initialValue
                    }
                    get {
                        access(keyPath: \\.explicit)
                        return _explicit
                    }
                    set {
                        withMutation(keyPath: \\.explicit) {
                            _explicit = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.explicit)
                        _$observationRegistrar.willSet(self, keyPath: \\.explicit)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.explicit)
                        }
                        yield &_explicit
                    }
                }
                var implicit: Int {
                    @storageRestrictions(initializes: _implicit)
                    init(initialValue) {
                        _implicit = initialValue
                    }
                    get {
                        access(keyPath: \\.implicit)
                        return _implicit
                    }
                    set {
                        withMutation(keyPath: \\.implicit) {
                            _implicit = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.implicit)
                        _$observationRegistrar.willSet(self, keyPath: \\.implicit)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.implicit)
                        }
                        yield &_implicit
                    }
                }

                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Model, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Model, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableWithConstants() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            class Model {
                let constant: String = "constant"
                var variable: Int = 10
            }
            """,
            expandedSource: """
            class Model {
                let constant: String = "constant"
                var variable: Int {
                    @storageRestrictions(initializes: _variable)
                    init(initialValue) {
                        _variable = initialValue
                    }
                    get {
                        access(keyPath: \\.variable)
                        return _variable
                    }
                    set {
                        withMutation(keyPath: \\.variable) {
                            _variable = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.variable)
                        _$observationRegistrar.willSet(self, keyPath: \\.variable)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.variable)
                        }
                        yield &_variable
                    }
                }

                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Model, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Model, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableWithAccessModifiers() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            public class Model {
                public var publicProp: String = "public"
                internal var internalProp: Int = 10
                private var privateProp: Bool = true
            }
            """,
            expandedSource: """
            public class Model {
                public var publicProp: String {
                    @storageRestrictions(initializes: _publicProp)
                    init(initialValue) {
                        _publicProp = initialValue
                    }
                    get {
                        access(keyPath: \\.publicProp)
                        return _publicProp
                    }
                    set {
                        withMutation(keyPath: \\.publicProp) {
                            _publicProp = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.publicProp)
                        _$observationRegistrar.willSet(self, keyPath: \\.publicProp)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.publicProp)
                        }
                        yield &_publicProp
                    }
                }
                internal var internalProp: Int {
                    @storageRestrictions(initializes: _internalProp)
                    init(initialValue) {
                        _internalProp = initialValue
                    }
                    get {
                        access(keyPath: \\.internalProp)
                        return _internalProp
                    }
                    set {
                        withMutation(keyPath: \\.internalProp) {
                            _internalProp = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.internalProp)
                        _$observationRegistrar.willSet(self, keyPath: \\.internalProp)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.internalProp)
                        }
                        yield &_internalProp
                    }
                }
                private var privateProp: Bool {
                    @storageRestrictions(initializes: _privateProp)
                    init(initialValue) {
                        _privateProp = initialValue
                    }
                    get {
                        access(keyPath: \\.privateProp)
                        return _privateProp
                    }
                    set {
                        withMutation(keyPath: \\.privateProp) {
                            _privateProp = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.privateProp)
                        _$observationRegistrar.willSet(self, keyPath: \\.privateProp)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.privateProp)
                        }
                        yield &_privateProp
                    }
                }

                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Model, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Model, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableWithAvailabilityAttribute() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @available(iOS 17.0, *)
            @Observable
            class Model {
                var name: String = "test"
            }
            """,
            expandedSource: """
            @available(iOS 17.0, *)
            class Model {
                var name: String {
                    @storageRestrictions(initializes: _name)
                    init(initialValue) {
                        _name = initialValue
                    }
                    get {
                        access(keyPath: \\.name)
                        return _name
                    }
                    set {
                        withMutation(keyPath: \\.name) {
                            _name = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.name)
                        _$observationRegistrar.willSet(self, keyPath: \\.name)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.name)
                        }
                        yield &_name
                    }
                }

                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Model, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Model, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableWithStaticProperties() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            class Model {
                static var staticProp: String = "static"
                var instanceProp: Int = 10
            }
            """,
            expandedSource: """
            class Model {
                static var staticProp: String = "static"
                var instanceProp: Int {
                    @storageRestrictions(initializes: _instanceProp)
                    init(initialValue) {
                        _instanceProp = initialValue
                    }
                    get {
                        access(keyPath: \\.instanceProp)
                        return _instanceProp
                    }
                    set {
                        withMutation(keyPath: \\.instanceProp) {
                            _instanceProp = newValue
                        }
                    }
                    _modify {
                        access(keyPath: \\.instanceProp)
                        _$observationRegistrar.willSet(self, keyPath: \\.instanceProp)
                        defer {
                            _$observationRegistrar.didSet(self, keyPath: \\.instanceProp)
                        }
                        yield &_instanceProp
                    }
                }

                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Model, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Model, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableInvalidOnStruct() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            struct Model {}
            """,
            expandedSource: """
            struct Model {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@Observable' cannot be applied to struct type 'Model'", line: 1, column: 1, severity: .error)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableInvalidOnEnum() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            enum Model {}
            """,
            expandedSource: """
            enum Model {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@Observable' cannot be applied to enumeration type 'Model'", line: 1, column: 1, severity: .error)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testObservableInvalidOnActor() throws {
        #if canImport(OpenObservationMacros)
        assertMacroExpansion(
            """
            @Observable
            actor Model {}
            """,
            expandedSource: """
            actor Model {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@Observable' cannot be applied to actor type 'Model'", line: 1, column: 1, severity: .error)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
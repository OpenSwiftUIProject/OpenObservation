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
import MacroTesting

#if canImport(OpenObservationMacros)
import OpenObservationMacros

let testMacros: [String: Macro.Type] = [
    "Observable": ObservableMacro.self,
    "ObservationTracked": ObservationTrackedMacro.self,
    "ObservationIgnored": ObservationIgnoredMacro.self,
]

let testMacros2: [String: MacroSpec] = [
    "Observable": .init(type: ObservableMacro.self, conformances: ["Observable"])
]
#endif

final class OpenObservationMacroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(OpenObservationMacros)
//        assertMacro {"""
//            @Observable
//            public class A {}
//            """
//        }
        
        assertMacroExpansion(
            """
            @Observable
            class A {}
            """,
            expandedSource: """
            class A {

                @ObservationIgnored private let _$observationRegistrar = OpenObservation.ObservationRegistrar()

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<A, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<A, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            
            extension A: OpenObservation.Observable {
            }
            """,
            macroSpecs: testMacros2
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(OpenObservationMacros)
//        assertMacroExpansion(
//            #"""
//            @Observable
//            class A {
//                @ObservationTracked var name: String
//                @ObservationIgnored var age: Int
//            }
//            """#,
//            expandedSource: #"""
//            class A {
//                var name: String {
//                    @storageRestrictions(initializes: _name)
//                    init(initialValue) {
//                        _name = initialValue
//                    }
//                    get {
//                        access(keyPath: \.name)
//                        return _name
//                    }
//                    set {
//                        withMutation(keyPath: \.name) {
//                            _name = newValue
//                        }
//                    }
//                    _modify {
//                        access(keyPath: \.name)
//                        _$observationRegistrar.willSet(self, keyPath: \.name)
//                        defer {
//                            _$observationRegistrar.didSet(self, keyPath: \.name)
//                        }
//                        yield &_name
//                    }
//                }
//                var age: Int
//
//                private let _$observationRegistrar = OpenObservation.ObservationRegistrar()
//
//                internal nonisolated func access<Member>(
//                    keyPath: KeyPath<A, Member>
//                ) {
//                    _$observationRegistrar.access(self, keyPath: keyPath)
//                }
//
//                internal nonisolated func withMutation<Member, MutationResult>(
//                    keyPath: KeyPath<A, Member>,
//                    _ mutation: () throws -> MutationResult
//                ) rethrows -> MutationResult {
//                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
//                }
//            }
//            """#,
//            macros: testMacros
//        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

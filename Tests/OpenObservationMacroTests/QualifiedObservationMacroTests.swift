import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import XCTest

#if canImport(OpenObservationMacros)
import OpenObservationMacros

final class QualifiedObservationMacroTests: XCTestCase {
    func testQualifiedIgnoredAndTrackedPropertiesAreNotTrackedAgain() throws {
        for name in ["ObservationIgnored", "ObservationTracked"] {
            for prefix in ["", "OpenObservation.", "OpenObservation::"] {
                let syntax: DeclSyntax = """
                class Model {
                    @\(raw: prefix)\(raw: name) var value = 0
                }
                """
                let declaration = try XCTUnwrap(syntax.as(ClassDeclSyntax.self))
                let property = try XCTUnwrap(declaration.memberBlock.members.first?.decl.as(VariableDeclSyntax.self))
                let attributes = try ObservableMacro.expansion(
                    of: AttributeSyntax("@Observable"),
                    attachedTo: declaration,
                    providingAttributesFor: property,
                    in: BasicMacroExpansionContext()
                )
                XCTAssertTrue(attributes.isEmpty, "Unexpected tracking for @\(prefix)\(name)")
            }
        }
    }

    func testAttributesFromOtherModulesDoNotSuppressTracking() throws {
        for separator in [".", "::"] {
            let syntax: DeclSyntax = """
            class Model {
                @Observation\(raw: separator)ObservationIgnored var value = 0
            }
            """
            let declaration = try XCTUnwrap(syntax.as(ClassDeclSyntax.self))
            let property = try XCTUnwrap(declaration.memberBlock.members.first?.decl.as(VariableDeclSyntax.self))
            let attributes = try ObservableMacro.expansion(
                of: AttributeSyntax("@Observable"),
                attachedTo: declaration,
                providingAttributesFor: property,
                in: BasicMacroExpansionContext()
            )
            XCTAssertEqual(attributes.count, 1)
        }
    }

    func testGeneratedObservationAttributesUseModuleSelectors() throws {
        let syntax: DeclSyntax = """
        class Model {
            var count = 0
        }
        """
        let declaration = try XCTUnwrap(syntax.as(ClassDeclSyntax.self))
        let property = try XCTUnwrap(declaration.memberBlock.members.first?.decl.as(VariableDeclSyntax.self))
        let context = BasicMacroExpansionContext()
        let attributes = try ObservableMacro.expansion(
            of: AttributeSyntax("@Observable"),
            attachedTo: declaration,
            providingAttributesFor: property,
            in: context
        )
        XCTAssertEqual(attributes.map(\.attributeName.trimmedDescription), ["OpenObservation::ObservationTracked"])

        let members = try ObservableMacro.expansion(
            of: AttributeSyntax("@Observable"),
            providingMembersOf: declaration,
            conformingTo: [],
            in: context
        )
        let registrar = try XCTUnwrap(members.first?.as(VariableDeclSyntax.self))
        XCTAssertEqual(
            registrar.attributes.first?.as(AttributeSyntax.self)?.attributeName.trimmedDescription,
            "OpenObservation::ObservationIgnored"
        )

        let peers = try ObservationTrackedMacro.expansion(
            of: AttributeSyntax("@ObservationTracked"),
            providingPeersOf: property,
            in: context
        )
        let storage = try XCTUnwrap(peers.first?.as(VariableDeclSyntax.self))
        XCTAssertEqual(
            storage.attributes.first?.as(AttributeSyntax.self)?.attributeName.trimmedDescription,
            "OpenObservation::ObservationIgnored"
        )
    }

    func testExplicitTrackedPropertiesGenerateUntrackedStorage() throws {
        for prefix in ["", "OpenObservation.", "OpenObservation::"] {
            let syntax: DeclSyntax = "@\(raw: prefix)ObservationTracked var count = 0"
            let property = try XCTUnwrap(syntax.as(VariableDeclSyntax.self))
            let peers = try ObservationTrackedMacro.expansion(
                of: AttributeSyntax("@\(raw: prefix)ObservationTracked"),
                providingPeersOf: property,
                in: BasicMacroExpansionContext()
            )
            let storage = try XCTUnwrap(peers.first?.as(VariableDeclSyntax.self))
            XCTAssertEqual(storage.bindings.first?.pattern.trimmedDescription, "_count")
            XCTAssertEqual(
                storage.attributes.compactMap { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription },
                ["OpenObservation::ObservationIgnored"]
            )
        }
    }
}
#endif

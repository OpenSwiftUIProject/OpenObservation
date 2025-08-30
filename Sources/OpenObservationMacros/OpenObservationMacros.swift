//
//  OpenObservationMacros.swift
//  OpenObservation
//
//  Created by Kyle on 2025/8/30.
//

import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct OpenObservationMacros: CompilerPlugin {
    var providingMacros: [any Macro.Type] = [
        ObservableMacro.self,
        ObservationTrackedMacro.self,
        ObservationIgnoredMacro.self,
    ]
}

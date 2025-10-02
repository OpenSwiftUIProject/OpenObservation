// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

func envEnable(_ key: String, default defaultValue: Bool = false) -> Bool {
    guard let value = Context.environment[key] else {
        print("[env] \(key) not set, using default: \(defaultValue)")
        return defaultValue
    }
    if value == "1" {
        print("[env] \(key)=1, enabled")
        return true
    } else if value == "0" {
        print("[env] \(key)=0, disabled")
        return false
    } else {
        print("[env] \(key)=\(value), using default: \(defaultValue)")
        return defaultValue
    }
}

#if os(macOS)
// NOTE: #if os(macOS) check is not accurate if we are cross compiling for Linux platform. So we add an env key to specify it.
let buildForDarwinPlatform = envEnable("OPENSWIFTUI_BUILD_FOR_DARWIN_PLATFORM", default: true)
#else
let buildForDarwinPlatform = envEnable("OPENSWIFTUI_BUILD_FOR_DARWIN_PLATFORM")
#endif

var sharedCXXSettings: [CXXSetting] = []
var sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v5),
]

let development = envEnable("OPENOBSERVATION_DEVELOPMENT", default: false)

// MARK: [env] OPENSWIFTUI_SWIFT_TOOLCHAIN_PATH

// Modified from: https://github.com/swiftlang/swift/blob/main/SwiftCompilerSources/Package.swift
//
// Create a couple of symlinks to an existing Ninja build:
//
//     ```shell
//     cd $OPENGRAPH_SWIFT_TOOLCHAIN_PATH
//     mkdir -p build/Default
//     ln -s build/<Ninja-Build>/llvm-<os+arch> build/Default/llvm
//     ln -s build/<Ninja-Build>/swift-<os+arch> build/Default/swift
//     ```
//
// where <$OPENGRAPH_SWIFT_TOOLCHAIN_PATH> is the parent directory of the swift repository.

let swiftToolchainPath = Context.environment["OPENSWIFTUI_SWIFT_TOOLCHAIN_PATH"] ?? (development ? "/Volumes/BuildMachine/swift-project" : "")
if !swiftToolchainPath.isEmpty {
    sharedCXXSettings.append(
        .unsafeFlags(
            [
                "-static",
                "-DCOMPILED_WITH_SWIFT",
                "-DPURE_BRIDGING_MODE",
                "-UIBOutlet", "-UIBAction", "-UIBInspectable",
                "-I\(swiftToolchainPath)/swift/include",
                "-I\(swiftToolchainPath)/swift/stdlib/public/SwiftShims",
                "-I\(swiftToolchainPath)/llvm-project/llvm/include",
                "-I\(swiftToolchainPath)/llvm-project/clang/include",
                "-I\(swiftToolchainPath)/build/Default/swift/include",
                "-I\(swiftToolchainPath)/build/Default/llvm/include",
                "-I\(swiftToolchainPath)/build/Default/llvm/tools/clang/include",
                "-DLLVM_DISABLE_ABI_BREAKING_CHECKS_ENFORCING", // Required to fix LLVM link issue
            ]
        )
    )
}

// MARK: [env] OPENSWIFTUI_SWIFT_TOOLCHAIN_VERSION

let swiftToolchainVersion = Context.environment["OPENSWIFTUI_SWIFT_TOOLCHAIN_VERSION"] ?? (development ? "6.0.2" : "")
if !swiftToolchainVersion.isEmpty {
    sharedCXXSettings.append(
        .define("OPENSWIFTUI_SWIFT_TOOLCHAIN_VERSION", to: swiftToolchainVersion)
    )
}

// MARK: - [env] OPENSWIFTUI_SWIFT_TOOLCHAIN_SUPPORTED

let swiftToolchainSupported = envEnable("OPENSWIFTUI_SWIFT_TOOLCHAIN_SUPPORTED", default: !swiftToolchainVersion.isEmpty)
if swiftToolchainSupported {
    sharedCXXSettings.append(.define("OPENSWIFTUI_SWIFT_TOOLCHAIN_SUPPORTED"))
    sharedSwiftSettings.append(.define("OPENSWIFTUI_SWIFT_TOOLCHAIN_SUPPORTED"))
}

// MARK: - [env] OPENSWIFTUI_LIBRARY_EVOLUTION

let libraryEvolutionCondition = envEnable("OPENSWIFTUI_LIBRARY_EVOLUTION", default: buildForDarwinPlatform)

if libraryEvolutionCondition {
    // NOTE: -enable-library-evolution will cause module verify failure for `swift build`.
    // Either set OPENATTRIBUTEGRAPH_LIBRARY_EVOLUTION=0 or add `-Xswiftc -no-verify-emitted-module-interface` after `swift build`
    sharedSwiftSettings.append(.unsafeFlags(["-enable-library-evolution", "-no-verify-emitted-module-interface"]))
}

let package = Package(
    name: "OpenObservation",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: "OpenObservation", targets: ["OpenObservation"]),
        .executable(name: "OpenObservationClient", targets: ["OpenObservationClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "601.0.0"..<"602.0.0"),
    ],
    targets: [
        .macro(
            name: "OpenObservationMacros",
            dependencies: [
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .target(
            name: "OpenObservation",
            dependencies: ["OpenObservationCxx", "OpenObservationMacros"],
            cxxSettings: sharedCXXSettings,
            swiftSettings: sharedSwiftSettings
        ),
        .target(
            name: "OpenObservationCxx",
            cxxSettings: sharedCXXSettings
        ),
        .executableTarget(
            name: "OpenObservationClient", dependencies: ["OpenObservation"],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "OpenObservationMacroTests",
            dependencies: [
                "OpenObservationMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
    ],
    cxxLanguageStandard: .cxx17
)

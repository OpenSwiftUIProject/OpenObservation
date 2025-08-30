//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#if OPENOBSERVATION_SWIFT_TOOLCHAIN_SUPPORTED
import OpenObservationCxx

@_silgen_name("_swift_openobservation_tls_get")
func _tlsGet() -> UnsafeMutableRawPointer?

@_silgen_name("_swift_openobservation_tls_set")
func _tlsSet(_ value: UnsafeMutableRawPointer?)

struct _ThreadLocal {
  static var value: UnsafeMutableRawPointer? {
    get {
      return _tlsGet()
    }
    set {
      _tlsSet(newValue)
    }
  }
}
#else

// https://github.com/swiftlang/swift-foundation/blob/main/Sources/FoundationEssentials/_ThreadLocal.swift
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WinSDK)
import WinSDK
#elseif canImport(Bionic)
import Bionic
#elseif arch(wasm32)
#else
#error("Unsupported platform")
#endif

struct _ThreadLocal {
  static var value: UnsafeMutableRawPointer? {
    get {
      #if canImport(Darwin)
      return pthread_getspecific(key.key)
      #elseif canImport(Glibc) || canImport(Musl) || canImport(Bionic)
      return pthread_getspecific(key.key)
      #elseif canImport(WinSDK)
      return FlsGetValue(key.key)
      #elseif arch(wasm32)
      return key.key.pointee
      #else
      #error("Unsupported platform")
      #endif
    }
    
    set {
      #if canImport(Darwin)
      pthread_setspecific(key.key, newValue)
      #elseif canImport(Glibc) || canImport(Musl) || canImport(Bionic)
      pthread_setspecific(key.key, newValue)
      #elseif canImport(WinSDK)
      FlsSetValue(key.key, newValue)
      #elseif arch(wasm32)
      key.key.pointee = newValue
      #else
      #error("Unsupported platform")
      #endif
    }
  }
  
  fileprivate static let key = Key()
  
  fileprivate struct Key {
    #if canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(Bionic)
    typealias PlatformKey = pthread_key_t
    #elseif canImport(WinSDK)
    typealias PlatformKey = DWORD
    #elseif arch(wasm32)
    typealias PlatformKey = UnsafeMutablePointer<UnsafeMutableRawPointer?>
    #else
    #error("Unsupported platform")
    #endif
    
    fileprivate let key: PlatformKey
    
    init() {
      #if canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(Bionic)
      var key = pthread_key_t()
      pthread_key_create(&key, nil)
      self.key = key
      #elseif canImport(WinSDK)
      self.key = FlsAlloc(nil)
      #elseif arch(wasm32)
      self.key = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: 1)
      self.key.initialize(to: nil)
      #else
      #error("Unsupported platform")
      #endif
    }
  }
}
#endif

//
//  Utils.swift
//  Mochi Wallet (macOS)
//
//  Created by Oliver Le on 13/12/2022.
//

import Foundation

enum Util {
  static func hardwareUUID() -> String? {
    let matchingDict = IOServiceMatching("IOPlatformExpertDevice")
    let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, matchingDict)
    defer{ IOObjectRelease(platformExpert) }
    
    guard platformExpert != 0 else { return nil }
    return IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? String
  }
}

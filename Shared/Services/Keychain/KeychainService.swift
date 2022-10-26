//
//  KeychainService.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 21/07/2022.
//

import Foundation
import KeychainAccess

protocol KeychainService {
  func set(_ value: String, key: String) throws
  func setSecurely(_ value: String, key: String) throws
  func setAndSync(_ value: String, key: String) throws
  func setAndSyncSecurely(_ value: String, key: String) throws
  func getString(_ key: String) throws -> String?
  func getStringSecurely(_ key: String) throws -> String?
  func remove(_ key: String) throws
  func removeAll() throws
}

final class KeychainServiceImpl: KeychainService {
  private let keychain: Keychain
  
  init(service: String = "so.console.bitswallet") {
    self.keychain = Keychain(service: service)
      .accessibility(.whenUnlocked)
  }
  
  func set(_ value: Data, key: String) throws {
    do {
      try keychain.set(value, key: key)
    } catch {
      throw error
    }
  }
  
  func getData(_ key: String) throws -> Data? {
    do {
      return try keychain.getData(key)
    } catch {
      throw error
    }
  }
    
  func set(_ value: String, key: String) throws {
    do {
      try keychain.set(value, key: key)
    } catch {
      throw error
    }
  }
  
  func setSecurely(_ value: String, key: String) throws {
    do {
      try keychain.accessibility(.whenUnlocked, authenticationPolicy: [.biometryAny, .or, .devicePasscode]).set(value, key: key)
    } catch {
      throw error
    }
  }
  
  func setAndSync(_ value: String, key: String) throws {
    do {
      try keychain.synchronizable(true).set(value, key: key)
    } catch {
      throw error
    }
  }
  
  func setAndSyncSecurely(_ value: String, key: String) throws {
    do {
      try keychain
        .synchronizable(true)
        .accessibility(.whenUnlocked, authenticationPolicy: [.biometryAny, .or, .devicePasscode])
        .set(value, key: key)
    } catch {
      throw error
    }
  }
  
  func getString(_ key: String) throws -> String? {
    do {
      return try keychain.getString(key)
    } catch {
      throw error
    }
  }
  
  func getStringSecurely(_ key: String) throws -> String? {
    do {
      return try keychain
        .accessibility(.whenUnlocked, authenticationPolicy: [.biometryAny, .or , .devicePasscode])
        .getString(key)
    } catch {
      throw error
    }
  }
  
  func remove(_ key: String) throws {
    do {
      try keychain.remove(key)
    } catch {
      throw error
    }
  }
  
  func removeAll() throws {
    do {
      try keychain.removeAll()
    } catch {
      throw error
    }
  }
}

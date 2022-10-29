//
//  LocalStorage.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 21/07/2022.
//

import Foundation

class LocalStorage {
  static let shared = LocalStorage()
  
  lazy var userDefaults: UserDefaults = {
    guard let userDefaults = UserDefaults(suiteName: "so.console") else {
      fatalError("Cannot init userDefault")
    }
    return userDefaults
  }()
  
  enum Keys {
    static let discordId = "discordId"
  }
  
  var discordId: String {
    get {
      return userDefaults.string(forKey: Keys.discordId) ?? ""
    }
    
    set {
      userDefaults.set(newValue, forKey: Keys.discordId)
    }
  }
}

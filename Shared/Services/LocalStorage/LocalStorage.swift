//
//  LocalStorage.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 21/07/2022.
//

import Foundation

class LocalStorage {
  private lazy var userDefaults: UserDefaults = {
    guard let userDefaults = UserDefaults(suiteName: "so.console") else {
      fatalError("Cannot init userDefault")
    }
    return userDefaults
  }()
  
  private enum Keys {
    static let currentWallet = "currentWallet"
    static let wallets = "wallets"
  }
     
  var currentWallet: WalletInfo? {
    get {
      guard let data = userDefaults.data(forKey: Keys.currentWallet),
            let walletInfo = try? JSONDecoder().decode(WalletInfo.self, from: data) else {
        return nil
      }
      return walletInfo
    }
    
    set {
      guard let walletInfo = newValue else {
        userDefaults.set(nil, forKey: Keys.currentWallet)
        return
      }
      let data = try? JSONEncoder().encode(walletInfo)
      userDefaults.set(data, forKey: Keys.currentWallet)
    }
  }
  
  var wallets: [WalletInfo] {
    get {
      guard let data = userDefaults.data(forKey: Keys.wallets),
            let walletInfos = try? JSONDecoder().decode([WalletInfo].self, from: data) else {
        return []
      }
      return walletInfos
    }
    
    set {
      let data = try? JSONEncoder().encode(newValue)
      userDefaults.set(data, forKey: Keys.wallets)
    }
  }
}

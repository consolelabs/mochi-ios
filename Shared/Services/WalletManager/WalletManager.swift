//
//  WalletManager.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 21/07/2022.
//

import Foundation
import web3swift

struct WalletInfo: Codable, Equatable {
  enum WalletType: Int, Codable {
    case hd
    case nonHD
    case readOnly
  }
 
  let id: String
  let address: String
  let name: String
  let emoticon: String
  let type: WalletType
  var isBackupManually: Bool
  var isBackupIcloud: Bool
  
  init(
    id: String = UUID().uuidString,
    address: String,
    name: String,
    emoticon: String,
    type: WalletInfo.WalletType,
    isBackupManually: Bool = false,
    isBackupIcloud: Bool = false
  ) {
    self.id = id
    self.address = address
    self.name = name
    self.emoticon = emoticon
    self.type = type
    self.isBackupManually = isBackupManually
    self.isBackupIcloud = isBackupIcloud
  }
}

protocol WalletManager {
  func getCurrentWallet() -> WalletInfo?
  func getWallets() -> [WalletInfo]
  func getCurrentWalletMnemonics() throws -> String
  func setCurrentWallet(wallet: WalletInfo)
  func deleteCurrentWallet() throws
  func createWallet() throws
  func addNewWalletFromCurrentMnemonics() throws
  func importWallet(name: String, mnemonics: String) throws
  func importWallet(name: String, privateKey: String) throws
  func importWallet(name: String, address: String)
  func backupCurrentWalletToIcloud() throws
  func backupCurrentWalletManually() throws
}

final class WalletManagerImpl: WalletManager {
  private let localStorage: LocalStorage
  private let keychainService: KeychainService
  
  init(
    localStorage: LocalStorage,
    keychainService: KeychainService
  ) {
    self.localStorage = localStorage
    self.keychainService = keychainService
  }
 
  // Save the public data to normal persistent service
  // Save the mnemonics to the keychain - a private place
  func createWallet() throws {
    do {
      let mnemonics = try generateSeedphrase()
      try importWallet(name: "My Wallet", mnemonics: mnemonics)
      if let wallet = getCurrentWallet() {
        try keychainService.setSecurely(mnemonics, key: wallet.address)
      }
    } catch {
      throw error
    }
  }
  
  func addNewWalletFromCurrentMnemonics() throws {
    do {
      let mnemonics = try self.getCurrentWalletMnemonics()
      let keystore = try BIP32Keystore(
        mnemonics: mnemonics,
        language: .english)
      let emoticon = getRandomEmo()
      try keystore?.createNewChildAccount()
      let walletCount = localStorage.wallets.count
      guard let address = keystore?.addresses?[walletCount].address else {
        throw NSError(domain: "Cannot get address from keystore", code: 0)
      }
      let wallet = WalletInfo(address: address, name: "My Wallet", emoticon: emoticon, type: .hd)
      let wallets = self.getWallets()
      localStorage.wallets = wallets + [wallet]
    } catch {
      throw error
    }
  }
  
  func setCurrentWallet(wallet: WalletInfo) {
    localStorage.currentWallet = wallet
  }
  
  func deleteCurrentWallet() throws {
    do {
      if let wallet = getCurrentWallet() {
        try keychainService.remove(wallet.address)
      }
      localStorage.currentWallet = nil
      localStorage.wallets = []
    } catch {
      throw error
    }
  }
  
  func importWallet(name: String, mnemonics: String) throws {
    do {
      let keystore = try BIP32Keystore(
        mnemonics: mnemonics,
        language: .english)
      let emoticon = getRandomEmo()
      guard let address = keystore?.addresses?.first?.address else {
        throw NSError(domain: "Cannot get address from keystore", code: 0)
      }
      let wallet = WalletInfo(address: address, name: name, emoticon: emoticon, type: .hd)
      localStorage.currentWallet = wallet
      localStorage.wallets = [wallet]
      try keychainService.set(mnemonics, key: address)
    } catch {
      throw error
    }
  }
  
  func importWallet(name: String, privateKey: String) throws {
    do {
      let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
      let dataKey = Data.fromHex(formattedKey)!
      let keystore = try EthereumKeystoreV3(privateKey: dataKey)
      let emoticon = getRandomEmo()
      guard let address = keystore?.addresses?.first?.address else {
        throw NSError(domain: "Cannot get address from keystore", code: 0)
      }
      let wallet = WalletInfo(address: address, name: name, emoticon: emoticon, type: .nonHD)
      localStorage.currentWallet = wallet
      localStorage.wallets = [wallet]
      try keychainService.set(privateKey, key: address)
    } catch {
      throw error
    }
  }
  
  func importWallet(name: String, address: String) {
    let emoticon = getRandomEmo()
    let wallet = WalletInfo(address: address, name: name, emoticon: emoticon, type: .readOnly)
    localStorage.currentWallet = wallet
    localStorage.wallets = [wallet]
  }
  
  func getCurrentWallet() -> WalletInfo? {
    return localStorage.currentWallet
  }
  
  func getWallets() -> [WalletInfo] {
    return localStorage.wallets
  }

  func getCurrentWalletMnemonics() throws -> String {
    do {
      guard let currentWallet = getCurrentWallet() else {
        throw NSError(domain: "Cannot get current wallet", code: 0)
      }
      guard let mnemonics = try keychainService.getStringSecurely(currentWallet.address) else {
        throw NSError(domain: "The mnemonics is invalid or corrupted", code: 0)
      }
      return mnemonics
    } catch {
      throw error
    }
  }
  
  func backupCurrentWalletToIcloud() throws {
    do {
      guard var currentWallet = getCurrentWallet() else {
        throw NSError(domain: "Cannot get current wallet", code: 0)
      }
      guard let mnemonics = try keychainService.getStringSecurely(currentWallet.address) else {
        throw NSError(domain: "The mnemonics is invalid or corrupted", code: 0)
      }
      try keychainService.setAndSyncSecurely(mnemonics, key: currentWallet.address)
      currentWallet.isBackupIcloud = true
      localStorage.currentWallet = currentWallet
    } catch {
      throw error
    }
  }
  
  func backupCurrentWalletManually() throws {
    guard var currentWallet = getCurrentWallet() else {
      throw NSError(domain: "Cannot get current wallet", code: 0)
    }
    currentWallet.isBackupManually = true
    localStorage.currentWallet = currentWallet
  }
  
  private func getRandomEmo() -> String {
    let emoStorage = "😀😃😄😁😆😅😅🤣☺️😊🙃😉😌😍😘😗😕😟😔😞😞😏🥳🤩😎🤓🧐🤨🤪😝😛😋😚😙🙁☹️😣😖😩🥺😢😭😤😠😡🤬🤯😳🥵🥶😱😨😴😲😮😧😦😯🙄😬😑😐😶🤥🤭🤔🤗😓😥😰🤤🤤😪😵🤐🥴🤢🤮🤧😷🤒🤕🤑🤠😈👿👹👺🤡💩👻💀☠️👽👾🤖🎃😺😸😹😻😼😽🙀😿😾"
    return String(emoStorage.randomElement() ?? "😀")
  }
  private func generateSeedphrase() throws -> String {
    let bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
    do {
      guard let mnemonics = try BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy) else {
        throw NSError(domain: "BIP39.generateMnemonics(bitsOfEntropy:) error, bitsOfEntropy: \(bitsOfEntropy)", code: 0)
      }
      return mnemonics
    } catch {
      throw error
    }
  }
}

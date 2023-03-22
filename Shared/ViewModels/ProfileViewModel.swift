//
//  ProfileViewModel.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 20/03/2023.
//

import Foundation
import SwiftUI
import Combine
import OSLog

struct WalletItem {
  let id: String
  let isEvm: Bool
  let address: String
  var ens: String
  let coin: Coin
}

extension WalletItem {
  static var mock: Self {
    return WalletItem(id: "0",
                      isEvm: true,
                      address: "0x5417A03667AbB6A059b3F174c1F67b1E83753046",
                      ens: "",
                      coin: Coin(id: "0", name: "ETH", symbol: "ETH", icon: "eth")
    )
  }
  
  static var mockWithENS: Self {
    return WalletItem(id: "0",
                      isEvm: true,
                      address: "0x5417A03667AbB6A059b3F174c1F67b1E83753046",
                      ens: "mochi.eth",
                      coin: Coin(id: "0", name: "ETH", symbol: "ETH", icon: "eth")
    )
  }
}

struct Coin {
  let id: String
  let name: String
  let symbol: String
  let icon: String
}


@MainActor
class ProfileViewModel: ObservableObject {
  private let mochiProfileService: MochiProfileService
  private let evmService: EVMService
  private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "mochi", category: "ProfileViewModel")
  private var subsscriptions = Set<AnyCancellable>()
  
  @Published var isLoading: Bool = false
  
  @Published var wallets: [WalletItem] = []
  
  @Published var error: String?
  var showError: Bool {
    return error != nil
  }
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
  
  init(
    mochiProfileService: MochiProfileService,
    evmService: EVMService
  ) {
    self.mochiProfileService = mochiProfileService
    self.evmService = evmService
    Task(priority: .high) {
      await fetchProfile()
    }
  }
  
  func fetchProfile(shouldShowLoading: Bool = true) async {
    guard !discordId.isEmpty else { return }
    
    if shouldShowLoading {
      self.isLoading = true
    }
    
    let result = await mochiProfileService.getByDiscord(id: discordId)
    switch result {
    case .success(let resp):
      let chainOnlyAccounts = resp.associatedAccounts
        .filter { acc in
          guard let platform = acc.platform else {
            return false
          }
          return [.solanaChain, .evmChain].contains(platform)
        }
      self.isLoading = false
      self.wallets = chainOnlyAccounts.map { acc in
        let coin = acc.platform == .evmChain
        ? Coin(id: "0", name: "Ethereum", symbol: "ETH", icon: "eth")
        : Coin(id: "1", name: "Solana", symbol: "SOL", icon: "sol")
        return WalletItem(
          id: acc.id,
          isEvm: acc.platform == .evmChain,
          address: acc.platformIdentifier,
          ens: "",
          coin: coin)
      }
      // resolve ens
      for (index, wallet) in wallets.enumerated() {
        guard wallet.isEvm else { continue }
        let ens = await self.resolveENS(address: wallet.address)
        self.wallets[index].ens = ens
      }
    case .failure(let error):
      self.isLoading = false
      self.error = error.customMessage
      logger.error("fetch mochi profile by discord id: \(self.discordId) failed, error: \(error)")
    }
  }
  
  private func resolveENS(address: String) async -> String {
    let result = await evmService.resolveENS(address: address)
    switch result {
    case .success(let resp):
      return resp.name ?? ""
    case .failure(let err):
      logger.error("resolve ens failed \(err)")
      return ""
    }
  }
}

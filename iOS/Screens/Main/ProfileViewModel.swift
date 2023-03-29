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

@MainActor
class ProfileViewModel: ObservableObject {
  private let mochiProfileService: MochiProfileService
  private let evmService: EVMService
  private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "mochi", category: "ProfileViewModel")
  private var subsscriptions = Set<AnyCancellable>()
  
  @Published var isLoading: Bool = false
  
  @Published var wallets: [WalletItem] = []
  @Published var socials: [SocialInfo] = []
  
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
    if shouldShowLoading {
      self.isLoading = true
    }
    let result = await mochiProfileService.getMe()
    switch result {
    case .success(let resp):
      self.isLoading = false
      
      self.socials = resp.associatedAccounts
        .filter { acc in
          guard let platform = acc.platform else { return false }
          return [.discord, .telegram].contains(platform)
        }
        .map { acc in
          var icon = "ico_telegram"
          if acc.platform == .discord {
            icon = "ico_discord"
          }
          // TODO: get platform username
          return SocialInfo(id: acc.platformIdentifier, icon: icon, name: "NA")
        }
      
      self.wallets = resp.associatedAccounts
        .filter { acc in
          guard let platform = acc.platform else { return false }
          return [.solanaChain, .evmChain].contains(platform)
        }
        .map { acc in
          let coin = acc.platform == .evmChain ? Coin.eth : Coin.sol
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
      logger.error("fetch mochi profile me failed, error: \(error)")
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

//
//  BitsfiApp.swift
//  Shared
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI
import web3swift

@main
struct BitsfiApp: App {
  @StateObject private var appState = AppState(
    walletManager: WalletManagerImpl(
      localStorage: LocalStorage(),
      keychainService: KeychainServiceImpl())
  )
  
  var body: some Scene {
    WindowGroup {
      VStack {
        switch appState.screenState {
        case .loading:
          ProgressView()
        case .onboarding:
          OnboardingView()
        case .main:
          ContentView()
        }
      }
      .environmentObject(appState)
      .onAppear {
        appState.fetchCurrentWallet()
      }
    }
  }
}

class AppState: ObservableObject {
  enum ScreenState {
    case loading
    case onboarding
    case main
  }
  
  private let walletManager: WalletManager
  
  init(walletManager: WalletManager) {
    self.walletManager = walletManager
  }
 
  @Published var screenState: ScreenState = .loading
  @Published var wallet: WalletInfo? = nil
  @Published var showSelectWallet: Bool = false
  
  var walletAddress: String? {
    return wallet?.address
  }
  
  var hasWallet: Bool {
    return wallet != nil
  }
  
  func fetchCurrentWallet() {
    wallet = walletManager.getCurrentWallet()
    screenState = hasWallet ? .main : .onboarding
  }
  
  func updateCurrentWallet(wallet: WalletInfo) {
    self.wallet = wallet
  }
  
  func createWallet() {
    screenState = .loading
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try self.walletManager.createWallet()
        DispatchQueue.main.async {
          self.wallet = self.walletManager.getCurrentWallet()
          self.screenState = .main
        }
      } catch {
        // TODO: Handle error
        print(error)
      }
    }
  }
  
  func importWallet(name: String, mnemonics: String) {
    screenState = .loading
    DispatchQueue.global().async {
      do {
        try self.walletManager.importWallet(name: name, mnemonics: mnemonics)
        DispatchQueue.main.async {
          self.wallet = self.walletManager.getCurrentWallet()
          self.screenState = .main
        }
      } catch {
        // TODO: Handle error
        print(error)
      }
    }
  }
  
  func importWallet(name: String, privateKey: String) {
    screenState = .loading
    DispatchQueue.global().async {
      do {
        try self.walletManager.importWallet(name: name, privateKey: privateKey)
        DispatchQueue.main.async {
          self.wallet = self.walletManager.getCurrentWallet()
          self.screenState = .main
        }
      } catch {
        // TODO: Handle error
        print(error)
      }
    }
  }
  
  func importWallet(name: String, address: String) {
    screenState = .loading
    self.walletManager.importWallet(name: name, address: address)
    DispatchQueue.main.async {
      self.wallet = self.walletManager.getCurrentWallet()
      self.screenState = .main
    }
  }
  
  func deleteWallet() {
    do {
      screenState = .loading
      try walletManager.deleteCurrentWallet()
      screenState = .onboarding
    } catch {
      // TODO: handle error properly
      print(error)
    }
  }
}

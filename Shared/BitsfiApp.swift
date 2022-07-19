//
//  BitsfiApp.swift
//  Shared
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI

@main
struct BitsfiApp: App {
  @StateObject private var viewModel = AppState()
  
  var body: some Scene {
    WindowGroup {
      VStack {
        ContentView()
//        if viewModel.hasWallet {
//          ContentView()
//        } else {
//          OnboardingView()
//        }
      }
      .environmentObject(viewModel)
    }
  }
}

class AppState: ObservableObject {
  @Published var walletAddress: String? = nil
  var hasWallet: Bool {
    guard let walletAddress = walletAddress else {
      return false
    }
    return !walletAddress.isEmpty
  }
  
  func setWallet(with address: String) {
    self.walletAddress = address
  }
}

struct WalletInfo {
  let address: String
  let privateKey: String
}

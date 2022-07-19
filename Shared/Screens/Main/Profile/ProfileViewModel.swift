//
//  ProfileViewModel.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 14/07/2022.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
  private lazy var walletConnect: WalletConnect = {
    let wc = WalletConnect(delegate: self)
    return wc
  }()
  
  @Published var url: URL? = nil
  @Published var showSelectWallet: Bool = false
  
  func viewDidApear() {
    
  }
  
  func connectWallet() {
//    let connectionUrl = walletConnect.connect()
//
//    /// https://docs.walletconnect.org/mobile-linking#for-ios
//    /// **NOTE**: Majority of wallets support universal links that you should normally use in production application
//    /// Here deep link provided for integration with server test app only
//    ///
//    ///
//    print(connectionUrl)
//    self.url = URL(string: "https://metamask.app.link/wc?uri=\(connectionUrl)")
    showSelectWallet.toggle()
  }
}

extension ProfileViewModel: WalletConnectDelegate {
  func failedToConnect() {
    print("Failed to connect")
  }
  
  func didConnect() {
    print("Did Connect")
  }
  
  func didDisconnect() {
    print("Did Disconnect")
  }
}

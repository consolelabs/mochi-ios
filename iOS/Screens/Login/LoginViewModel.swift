//
//  LoginViewModel.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 24/03/2023.
//

import SwiftUI
import OSLog
import Combine

enum MochiError: Error {
  case custom(String)
}

@MainActor
class LoginViewModel: ObservableObject {
 
  var openURL = PassthroughSubject<URL, Never>()
  var accessToken = PassthroughSubject<String, Never>()
  
  private let phantomWalletService = PhantomWalletService()
  private let mochiProfileService = MochiProfileServiceImp(keychainService: KeychainServiceImpl())
  
  private let logger = Logger(subsystem: "so.console.mochi", category: "LoginViewModel")
  private let authCode = String.random(length: 5)
  
  func onOpenURL(url: URL) {
    guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      logger.log(level: .error, "invalid url")
      return
    }
    logger.debug("Received deeplink \(url)")
    switch urlComponents.host {
    case "onPhantomConnected":
      self.onPhantomConnected(queryItems: urlComponents.queryItems ?? [])
    case "onPhantomSignedMessage":
      self.onPhantomSignedMessage(queryItems: urlComponents.queryItems ?? [])
    default:
      logger.info("not supported")
    }
  }
  
  func loginWithPhantom() {
    let appURL = "https://mochi.gg"
    let redirectLink = "so.console.mochi://onPhantomConnected"
    guard let deeplink = try? phantomWalletService.getDeeplink(for: .connect(appURL: appURL, redirectLink: redirectLink)) else {return}
    openURL.send(deeplink)
  }
    
  private func onPhantomConnected(queryItems: [URLQueryItem]) {
    do {
       _ = try phantomWalletService.getPhantomConnectData(queryItems: queryItems)
      signMessagePhantomWallet()
    } catch {
      logger.error("connect phantom wallet failed: \(error)")
    }
  }
  
  private func onPhantomSignedMessage(queryItems: [URLQueryItem]) {
    do {
      let signature = try phantomWalletService.getSignature(queryItems: queryItems)
      let walletAddress = try phantomWalletService.getWalletAddress()
      authWithSolana(code: authCode, signature: signature, walletAddress: walletAddress)
    } catch {
      logger.error("sign message phantom wallet failed: \(error)")
    }
  }
  
  private func signMessagePhantomWallet() {
    let message = "This will help us connect your discord account to the wallet address.\n\nMochiBotCode=\(authCode)"
    let redirectLink = "so.console.mochi://onPhantomSignedMessage"
    guard let deeplink = try? phantomWalletService.getDeeplink(for: .sign(message: message, redirectLink: redirectLink)) else {return}
    openURL.send(deeplink)
  }
  
  private func authWithSolana(code: String, signature: String, walletAddress: String) {
    Task(priority: .high) {
      let result = await mochiProfileService.authBySolana(code: code, signature: signature, walletAddress: walletAddress)
      switch result {
      case .success(let resp):
        self.accessToken.send(resp.data.accessToken)
      case .failure(let error):
        logger.error("mochiProfileService.authBySolana failed, code: \(code), signature: \(signature), walletAddrres: \(walletAddress), error: \(error)")
      }
    }
  }
}

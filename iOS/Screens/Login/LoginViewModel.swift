//
//  LoginViewModel.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 24/03/2023.
//

import SwiftUI
import OSLog
import Combine
import AuthenticationServices
import metamask_ios_sdk

enum MochiError: Error {
  case custom(String)
}

@MainActor
class LoginViewModel: NSObject, ObservableObject {

  // MARK: Public states
  var openURL = PassthroughSubject<URL, Never>()
  var accessToken = PassthroughSubject<String, Never>()
  
  // MARK: Private states
  private let authCode = String.random(length: 5)
  private var signMessage: String {
    return "This will help us connect your discord account to the wallet address.\n\nMochiBotCode=\(authCode)"
  }
  private var cancellables: Set<AnyCancellable> = []


  // MARK: Services
  @ObservedObject
  private var ethereum = MetaMaskSDK.shared.ethereum
  private let phantomWalletService = PhantomWalletService()
  private let mochiProfileService = MochiProfileServiceImp(keychainService: KeychainServiceImpl())
  private let logger = Logger(subsystem: "so.console.mochi", category: "LoginViewModel")
 
  // MARK: - Public methods
  
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
  
  func loginWithMetamask() {
    guard !ethereum.connected else {
      signMessageMetamaskWallet()
      return
    }
    
    let dapp = Dapp(name: "Mochi", url: "https://mochi.gg")
    // This is the same as calling "eth_requestAccounts"
    ethereum.connect(dapp)?
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
      switch completion {
      case let .failure(error):
        self?.logger.error("connect to metamask error: \(error)")
      default: break
      }
    }, receiveValue: { [weak self] result in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self?.signMessageMetamaskWallet()
      }
    }).store(in: &cancellables)
  }
  
  func loginWithPhantom() {
    let appURL = "https://mochi.gg"
    let redirectLink = "so.console.mochi://onPhantomConnected"
    guard let deeplink = try? phantomWalletService.getDeeplink(for: .connect(appURL: appURL, redirectLink: redirectLink)) else {return}
    openURL.send(deeplink)
  }
  
  func loginWithDiscord() {
    let scheme = "so.console.mochi"
    var urlComponent = URLComponents()
    urlComponent.scheme = "https"
    urlComponent.host = "api.mochi-profile.console.so"
    urlComponent.path = "/api/v1/profiles/auth/discord"
    urlComponent.queryItems = [
      .init(name: "url_location", value: "\(scheme)://onDiscordAuth")
    ]
    guard let authURL = urlComponent.url else { return}
    
    let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { callbackURL, error in
      guard error == nil, let callbackURL = callbackURL else {
        self.logger.error("login with discord failed, error: \(error)")
        return
      }
      let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
      guard let token = queryItems?.filter({ $0.name == "token" }).first?.value else {
        self.logger.error("login with discord failed, token is empty")
        return
      }
      self.accessToken.send(token)
    }
    
    session.presentationContextProvider = self
    session.start()
  }
  
  // MARK: - Private methods

  private func signMessageMetamaskWallet() {
    let from = ethereum.selectedAddress
    let params = [signMessage, from]
    let signRequest = EthereumRequest(
      method: .personalSign,
      params: params
    )
    ethereum.request(signRequest)?.sink(receiveCompletion: { [unowned self] completion in
      switch completion {
      case let .failure(error):
        self.logger.error("sign message metamask failed, error: \(error)")
      default: break
      }
    }, receiveValue: { [weak self] signature in
      guard let self, let signature = signature as? String else {return}
      self.authWithEVM(code: self.authCode, signature: signature, walletAddress: from)
    }).store(in: &cancellables)
    
    self.openURL.send(URL(string: "https://metamask.app.link")!)
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
    let redirectLink = "so.console.mochi://onPhantomSignedMessage"
    guard let deeplink = try? phantomWalletService.getDeeplink(for: .sign(message: signMessage, redirectLink: redirectLink)) else {return}
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
  
  private func authWithEVM(code: String, signature: String, walletAddress: String) {
    Task(priority: .high) {
      let result = await mochiProfileService.authByEVM(code: code, signature: signature, walletAddress: walletAddress)
      switch result {
      case .success(let resp):
        self.accessToken.send(resp.data.accessToken)
      case .failure(let error):
        logger.error("mochiProfileService.authByEVM failed, code: \(code), signature: \(signature), walletAddrres: \(walletAddress), error: \(error)")
      }
    }
  }
}

extension LoginViewModel: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
}

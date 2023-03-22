//
//  AppStateManager.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 22/03/2023.
//

import SwiftUI
import OSLog

@MainActor
class AppStateManager: ObservableObject {
  enum AppState {
    case logedOut
    case logedIn(auth: AuthType)
  }
  
  enum AuthType {
    case wallet
    case social
  }
  
  struct WalletAuthPayload {
  }
  
  struct SocialAuthPayload {
  }
  
  private let logger = Logger(subsystem: "so.console.mochi", category: "AppStateManager")
  private let discordService: DiscordService
  private let keychainService: KeychainService
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
  
  @AppStorage("discordAccessToken", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordAccessToken: String = "" {
    didSet {
      fetchDiscordUser()
    }
  }
  
  @AppStorage("username", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var username: String = ""
  
  @AppStorage("avatar", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var avatar: String = ""
  
  @AppStorage("appleUserId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var appleUserId: String = ""
  
  @AppStorage("appleEmail", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var appleEmail: String = ""
  
  @AppStorage("appleName", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var appleName: String = ""
  
  @Published var isLoading: Bool = false
  @Published var appState: AppState = .logedOut
  
  var isLogin: Bool {
    return !discordAccessToken.isEmpty && !discordId.isEmpty
  }
  
  init(
    discordService: DiscordService,
    keychainService: KeychainService
  ) {
    self.discordService = discordService
    self.keychainService = keychainService
    fetchAppState()
  }
  
  func logOut() {
    // Discord
    self.discordAccessToken = ""
    self.discordId = ""
    self.username = ""
    self.avatar = ""
    
    // Apple
    self.appleUserId = ""
    self.appleName = ""
    self.appleEmail = ""
    
    fetchAppState()
  }
  
  func loginWithDiscord(accessToken: String) {
    self.discordAccessToken = accessToken
  }
  
  func loginWithApple(userId: String, email: String, name: String) {
    self.appleUserId = userId
    self.appleEmail = email
    self.appleName = name
    fetchAppState()
  }
  
  func getProfile() -> Profile {
    return Profile(
      id: UUID().uuidString,
      avatar: avatar,
      name: username,
      discord: SocialInfo(icon: "discord", name: username),
      twitter: nil,
      telegram: nil
    )
  }
  
  func fetchAppState() {
    if !discordAccessToken.isEmpty && !discordId.isEmpty {
      self.appState = .logedIn(auth: AuthType.social)
      return
    }
    
    if !appleUserId.isEmpty {
      self.appState = .logedIn(auth: .social)
      return
    }
    
    self.appState = .logedOut
  }
  
  func fetchDiscordUser() {
    guard !discordAccessToken.isEmpty else {
      return
    }
    isLoading = true
    Task {
      let result = await discordService.getCurrentUser()
      isLoading = false
      switch result {
      case .success(let user):
        self.discordId = user.id
        self.avatar = "https://cdn.discordapp.com/avatars/\(user.id)/\(user.avatar ?? "")"
        self.username = user.username + "#" + user.discriminator
        fetchAppState()
      case .failure(let error):
        logger.error("Fetch discord user error: \(error.customMessage)")
      }
    }
  }
}

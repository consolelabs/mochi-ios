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
    case logedIn
  }
  
  private let logger = Logger(subsystem: "so.console.mochi", category: "AppStateManager")
  private let mochiProfileService: MochiProfileService
  private let discordService: DiscordService
  private let keychainService: KeychainService
 
  @Published var profile: Profile?
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
  
  @AppStorage("appleUserId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var appleUserId: String = ""
  
  @AppStorage("appleEmail", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var appleEmail: String = ""
  
  @AppStorage("appleName", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var appleName: String = ""
  
  @Published var isLoading: Bool = false
  @Published var appState: AppState = .logedOut
  
  init(
    discordService: DiscordService,
    keychainService: KeychainService,
    mochiProfileService: MochiProfileService
  ) {
    self.discordService = discordService
    self.keychainService = keychainService
    self.mochiProfileService = mochiProfileService
    fetchAppState()
  }
  
  func logOut() {
    // Discord
    self.discordId = ""
    
    // Apple
    self.appleUserId = ""
    self.appleName = ""
    self.appleEmail = ""
    
    do {
      try keychainService.remove("accessToken")
    } catch {
      logger.error("cannot remove access token, error: \(error)")
    }
    
    fetchAppState()
  }

  func login(accessToken: String) {
    do {
      logger.info("access token: \(accessToken, privacy: .private)")
      try keychainService.set(accessToken, key: "accessToken")
      fetchAppState()
    } catch {
      logger.error("cannot save access token, error: \(error)")
    }
  }
  
  func loginWithApple(userId: String, email: String, name: String) {
    self.appleUserId = userId
    self.appleEmail = email
    self.appleName = name
    fetchAppState()
  }
  
  func fetchAppState() {
    guard let accessToken = try? keychainService.getString("accessToken"), !accessToken.isEmpty else {
      self.appState = .logedOut
      return
    }
    
    self.appState = .logedIn
    fetchUserProfile()
  }
  
  func fetchUserProfile() {
    Task {
      let result = await mochiProfileService.getMe()
      switch result {
      case .success(let resp):
        let avatar = resp.avatar.isEmpty ? "" : resp.avatar
        let profileName = resp.profileName.isEmpty ? "username" : resp.profileName
        let discordAcc = resp.associatedAccounts.first(where: {$0.platform == .discord})
        self.discordId = discordAcc?.platformIdentifier ?? ""
        self.profile = Profile(id: resp.id, avatar: avatar, profileName: profileName)
      case .failure(let error):
        logger.error("Fetch mochi profile error: \(error)")
      }
    }
  }
}

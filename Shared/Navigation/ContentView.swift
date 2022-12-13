//
//  ContentView.swift
//  Shared
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI
import OSLog

struct ContentView: View {
  #if os(iOS)
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  #endif
 
  @StateObject var appStateManager: AppStateManager = AppStateManager(discordService: DiscordServiceImpl())
  
  var body: some View {
    #if os(iOS)
    Group {
      switch appStateManager.appState {
      case .discordLogin, .appleLogin:
        AppTabNavigation()
      case .logout:
        AuthView()
      }
    }
    .overlay {
      if appStateManager.isLoading {
        ActivityIndicator()
          .frame(width: 40, height: 40)
          .foregroundColor(.appPrimary)
      }
    }
    .environmentObject(appStateManager)
    #elseif os(macOS)
    AppSidebarNavigation()
  
    #endif
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

@MainActor
class AppStateManager: ObservableObject {
  enum AppState {
    case logout
    case appleLogin
    case discordLogin
  }
  
  private let logger = Logger(subsystem: "so.console.mochi", category: "AppStateManager")
  private let discordService: DiscordService
 
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
  @Published var appState: AppState = .logout
  
  var isLogin: Bool {
    return !discordAccessToken.isEmpty && !discordId.isEmpty
  }
    
  init(discordService: DiscordService) {
    self.discordService = discordService
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
    
  func fetchAppState() {
    if !discordAccessToken.isEmpty && !discordId.isEmpty {
      self.appState = .discordLogin
      return
    }
    
    if !appleUserId.isEmpty {
      self.appState = .appleLogin
      return
    }
   
    self.appState = .logout
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

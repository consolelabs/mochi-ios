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
      if appStateManager.isLogin {
        AppTabNavigation()
      } else {
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
    WatchlistView(vm: WatchlistViewModel(defiService: DefiServiceImpl()))
      .frame(minWidth: 380,
             idealWidth: 500,
             minHeight: 380,
             idealHeight: 450)
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
  
  @State var isLoading: Bool = false
  
  var isLogin: Bool {
    return !discordAccessToken.isEmpty && !discordId.isEmpty
  }
  
    
  init(discordService: DiscordService) {
    self.discordService = discordService
  }
  
  func logOut() {
    self.discordAccessToken = ""
    self.discordId = ""
    self.username = ""
    self.avatar = ""
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
      case .failure(let error):
        logger.error("Fetch discord user error: \(error.customMessage)")
      }
    }
  }
}

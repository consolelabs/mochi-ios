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
  
  @StateObject var appStateManager: AppStateManager = AppStateManager(
    discordService: DiscordServiceImpl(),
    keychainService: KeychainServiceImpl()
  )
  
  var body: some View {
#if os(iOS)
    Group {
      switch appStateManager.appState {
      case .logedIn(let authType):
        switch authType {
        case .wallet:
          MainView(profile: appStateManager.getProfile())
        case .social:
          MainView(profile: appStateManager.getProfile())
        }
      case .logedOut:
        OnboardingView()
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


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
    keychainService: KeychainServiceImpl(),
    mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl())
  )
  
  var body: some View {
#if os(iOS)
    Group {
      switch appStateManager.appState {
      case .logedIn:
        MainView(
          watchlistVM: WatchlistViewModel(defiService: DefiServiceImpl()),
          profileVM: ProfileViewModel(
            mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl()),
            evmService: EVMServiceImp()
          )
        )
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


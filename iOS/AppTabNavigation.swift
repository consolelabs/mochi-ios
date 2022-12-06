//
//  AppTabNavigation.swift
//  Bitsfi
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI

struct AppTabNavigation: View {
  
  enum Tab {
    case watchlist
    case alert
    case setting
  }
  
  @EnvironmentObject var appStateManager: AppStateManager

  @State private var selection: Tab = .watchlist
  @State private var showDiscordConnect: Bool = false
  
  var body: some View {
    TabView(selection: $selection) {
      WatchlistView(vm: WatchlistViewModel(defiService: DefiServiceImpl()))
      .tabItem {
        let watchlistText = Text("Watchlist", comment: "Watchlist tab")
        Label {
          watchlistText
        } icon: {
          Image(systemName: "star")
        }.accessibility(label: watchlistText)
      }
      .tag(Tab.watchlist)
     
      if appStateManager.appState == .discordLogin {
        AlertListView(vm: AlertListViewModel(alertService: PriceAlertServiceImpl()))
          .tabItem {
            let watchlistText = Text("Alert", comment: "Watchlist tab")
            Label {
              watchlistText
            } icon: {
              Image(systemName: "bell")
            }.accessibility(label: watchlistText)
          }
          .tag(Tab.alert)
      }
      
      SettingsView()
        .tabItem {
          let settingText = Text("Settings", comment: "Settings tab")
          Label {
            settingText
          } icon: {
            Image(systemName: "gearshape")
          }.accessibility(label: settingText)
        }
        .tag(Tab.setting)
    }
    .sheet(isPresented: $showDiscordConnect) {
      ConnectToDiscordView()
    }
    .onChange(of: appStateManager.discordId) { discordId in
      if !discordId.isEmpty {
        showDiscordConnect = false
      }
    }
    .task {
      if appStateManager.appState == .appleLogin {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          showDiscordConnect = true
        }
      }
    }
  }
}

struct AppTabNavigation_Previews: PreviewProvider {
  static var previews: some View {
    AppTabNavigation()
  }
}

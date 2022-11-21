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
  
  @State private var selection: Tab = .watchlist
  
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
  }
}

struct AppTabNavigation_Previews: PreviewProvider {
  static var previews: some View {
    AppTabNavigation()
  }
}

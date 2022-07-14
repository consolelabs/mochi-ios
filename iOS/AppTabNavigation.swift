//
//  AppTabNavigation.swift
//  Bitsfi
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI

struct AppTabNavigation: View {
  
  enum Tab {
    case dashboard
    case market
    case profile
  }
  
  @State private var selection: Tab = .market
  
  var body: some View {
    TabView(selection: $selection) {
      NavigationView {
        Text("🏗 WIP")
          .font(.title)
      }
      .tabItem {
        let dashboardText = Text("Dashboard", comment: "Dashboard tab title")
        Label {
          dashboardText
        } icon: {
          Image(systemName: "square.split.2x2")
        }.accessibility(label: dashboardText)
      }
      .tag(Tab.dashboard)
      
      
      NavigationView {
        MarketView()
      }
      .tabItem {
        let marketText = Text("Market", comment: "Market tab title")
        Label {
          marketText
        } icon: {
          Image(systemName: "chart.line.uptrend.xyaxis")
        }.accessibility(label: marketText)
      }
      .tag(Tab.market)
      
      ProfileView()
        .tabItem {
          let profileText = Text("Profile", comment: "Profile tab title")
          Label {
            profileText
          } icon: {
            Image(systemName: "person")
          }.accessibility(label: profileText)
        }
        .tag(Tab.profile)
    }
  }
}

struct AppTabNavigation_Previews: PreviewProvider {
  static var previews: some View {
    AppTabNavigation()
  }
}

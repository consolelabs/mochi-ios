//
//  AppSidebarNavigation.swift
//  Bitsfi
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI

struct AppSidebarNavigation: View {
  
  enum NavigationItem {
    case watchlist
    case priceAlert
  }
  
  @State private var selection: NavigationItem? = .watchlist
  
  var body: some View {
    NavigationView {
      List {
        NavigationLink(tag: NavigationItem.watchlist, selection: $selection) {
          WatchlistView(vm: WatchlistViewModel(defiService: DefiServiceImpl()))
            .frame(minWidth: 380,
                   idealWidth: 500,
                   minHeight: 380,
                   idealHeight: 450)
        } label: {
          Label("Watchlist", systemImage: "star.fill")
        }
        
        NavigationLink(tag: NavigationItem.priceAlert, selection: $selection) {
          AlertListView(vm: AlertListViewModel(alertService: PriceAlertServiceImpl()))
        } label: {
          Label("Alerts", systemImage: "bell.fill")
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigation) {
        Button(action: toggleSidebar) {
          Image(systemName: "sidebar.leading")
        }
      }
    }
  }
  
  private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
  }
}

struct AppSidebarNavigation_Previews: PreviewProvider {
  static var previews: some View {
    AppSidebarNavigation()
  }
}


//
//  ContentView.swift
//  Shared
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI

struct ContentView: View {
  #if os(iOS)
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  #endif
  
  var body: some View {
    #if os(iOS)
    AppTabNavigation()
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

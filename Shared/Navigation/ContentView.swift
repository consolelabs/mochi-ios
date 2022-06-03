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
    if horizontalSizeClass == .compact {
      AppTabNavigation()
    } else {
      AppSidebarNavigation()
    }
    #else
    AppSidebarNavigation()
    #endif
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

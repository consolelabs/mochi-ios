//
//  BitsfiApp.swift
//  Shared
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI

@main
struct MochiWalletApp: App {
  #if os(macOS)
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  private var appDelegate
  #endif
  
  @State var openSetting = false
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    #if os(macOS)
    .windowToolbarStyle(.unifiedCompact(showsTitle: true))
    #endif
        
    #if os(macOS)
    Settings {
      SettingsView()
    }
    #endif
  }
}

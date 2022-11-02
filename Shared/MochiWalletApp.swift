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

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

//
//  SettingsView.swift
//  Mochi Wallet (macOS)
//
//  Created by Oliver Le on 07/11/2022.
//

import SwiftUI
import AppKit
import WidgetKit

struct SettingsView: View {
  enum Tabs {
    case general
    case about
  }
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = "" {
    didSet {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
  
  @State var showDiscordIDGuide: Bool = false
  
  var body: some View {
    TabView {
      Form {
        HStack {
          TextField("Discord ID", text: $discordId)
          Button(action: {showDiscordIDGuide.toggle()}) {
            Image(systemName: "questionmark.circle.fill")
          }
          .buttonStyle(.borderless)
          .popover(isPresented: $showDiscordIDGuide) {
            Image("guide")
              .resizable()
              .scaledToFit()
              .frame(height: 300)
          }
        }
      }
      .padding()
      .frame(width: 480, height: 100)
      .tabItem {
        Label("General", systemImage: "gear")
      }
      .tag(Tabs.general)
      
      AboutSettingView()
        .tabItem {
          Label("About", systemImage: "info.circle.fill")
        }
        .tag(Tabs.about)
      .frame(width: 480, height: 270)
    }
  }
}

struct AboutSettingView: NSViewControllerRepresentable {
  typealias NSViewControllerType = AboutViewController
  
  func makeNSViewController(context: Context) -> AboutViewController {
    return AboutViewController()
  }
  
  func updateNSViewController(_ nsViewController: AboutViewController, context: Context) {
  }
}

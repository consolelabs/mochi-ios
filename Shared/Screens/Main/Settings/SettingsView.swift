//
//  SettingsView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 22/07/2022.
//

import SwiftUI
import WidgetKit
import SDWebImageSwiftUI

struct SettingsView: View {
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = "" {
    didSet {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
 
  @EnvironmentObject var appStateManager: AppStateManager
  
  var body: some View {
    NavigationView {
      List {
        Section {
          HStack {
            Text("Username")
            
            Spacer()
            
            WebImage(url: URL(string: appStateManager.avatar))
              .resizable()
              .transition(.fade(duration: 0.5))
              .scaledToFit()
              .clipShape(Circle())
              .frame(width: 20, height: 20)
            
            Text(appStateManager.username)
          }
          HStack {
            Text("Discord ID")
            
            Spacer()
            TextField("Text", text: .constant(discordId))
              .multilineTextAlignment(.trailing)
              .disabled(true)
          }
        }
        Section {
          HStack {
            Text("🔗")
            Link("Share Mochi Wallet", destination: URL(string: "http://getmochi.co/")!)
          }
          
          HStack {
            Text("🐦")
            Link("Follow us on Twitter", destination: URL(string: "https://twitter.com/getmochi_bot")!)
          }
          
          HStack {
            Text("💬")
            Link("Feedback and Support", destination: URL(string: "http://getmochi.co/")!)
          }
        }
        Section {
          Button(action: { appStateManager.logOut() }) {
            Text("Log Out")
              .foregroundColor(.red)
              .font(.system(.body, design: .rounded).weight(.medium))
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.borderless)
        } footer: {
        HStack {
          Spacer()
          Text("\(Bundle.main.releaseVersionNumber ?? "1") (\(Bundle.main.buildVersionNumber ?? "0"))")
            .foregroundColor(.subtitle)
            .font(.system(.footnote, design: .rounded))
          Spacer()
        }
      }
      }
      .foregroundColor(.title)
      .font(.system(.body, design: .rounded))
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}

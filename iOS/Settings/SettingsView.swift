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
  
  @State private var showConnectToDiscord: Bool = false
  
  var body: some View {
    NavigationView {
      List {
        Group {
          switch appStateManager.appState {
          case .appleLogin:
            Section {
              Button(action: { showConnectToDiscord = true }) {
                HStack {
                  Image("discord")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                  Text("Connect to Discord")
                }
                .font(.system(.body, design: .rounded).weight(.medium))
              }
              .buttonStyle(.borderless)
            }
          case .discordLogin:
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
          case .logout:
            EmptyView()
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
      .sheet(isPresented: $showConnectToDiscord) {
        ConnectToDiscordView()
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
    .navigationViewStyle(.stack)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}

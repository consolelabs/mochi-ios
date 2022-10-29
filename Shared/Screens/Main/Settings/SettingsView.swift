//
//  SettingsView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 22/07/2022.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var appState: AppState
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""

  private var wallet: WalletInfo? {
    return appState.wallet
  }
  
  private var isBackup: Bool {
    guard let wallet = wallet else {
      return false
    }
    return wallet.isBackupIcloud || wallet.isBackupManually
  }
  
  var body: some View {
    NavigationView {
      List {
        Section {
          HStack {
            Text("Discord ID")
              .foregroundColor(.title)
            Spacer()
            TextField("Text", text: $discordId)
              .multilineTextAlignment(.trailing)
              .foregroundColor(.title)
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
        } footer: {
          HStack {
            Spacer()
            Text("\(Bundle.main.releaseVersionNumber ?? "1") (\(Bundle.main.buildVersionNumber ?? "0"))")
            Spacer()
          }
        }
        .foregroundColor(.title)
      }
      .onAppear(perform: {
        appState.fetchCurrentWallet()
      })
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

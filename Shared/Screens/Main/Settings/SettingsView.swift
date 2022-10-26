//
//  SettingsView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 22/07/2022.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var appState: AppState
  
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
          NavigationLink(destination: BackupWalletContainerView()) {
            HStack {
              Text("Backup")
                .foregroundColor(.title)
              Spacer()
              Image(systemName: isBackup ? "checkmark.icloud.fill" : "exclamationmark.icloud.fill")
                .foregroundColor(isBackup ? .green : .orange)
            }
          }
          Button(action: {}) {
            HStack {
              Text("Theme")
                .foregroundColor(.title)
              Spacer()
              Text("System")
                .foregroundColor(.subtitle)
            }
          }
          .disabled(true)
        }
        Section {
          HStack {
            Text("🔗")
            Link("Share Mochi Wallet", destination: URL(string: "http://getmochi.co/")!)
          }
          
          HStack {
            Text("🧠")
            Link("Learn about WEB3", destination: URL(string: "http://getmochi.co/")!)
          }
          
          HStack {
            Text("🐦")
            Link("Follow Us on Twitter", destination: URL(string: "https://twitter.com/getmochi_bot")!)
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

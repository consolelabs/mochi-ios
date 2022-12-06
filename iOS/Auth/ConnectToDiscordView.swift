//
//  ConnectToDiscordView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 07/12/2022.
//

import SwiftUI

struct ConnectToDiscordView: View {
  @EnvironmentObject var appStateManager: AppStateManager
  
  @State private var showDiscordLogin: Bool = false
  @State private var token: String = ""
  @State private var error: String = ""
 
  var body: some View {
    VStack {
      Image("icon")
        .resizable()
        .scaledToFill()
        .frame(width: 150, height: 150, alignment: .center)
        .padding(.vertical, 40)
     
      Text("Connect to Discord")
        .font(.system(.largeTitle, design: .rounded).weight(.bold))
        .foregroundColor(.title)
      
      Text("Unlock more alpha features, and sync data with the Mochi Discord bot.")
        .multilineTextAlignment(.center)
        .font(.system(.body, design: .rounded).weight(.medium))
        .foregroundColor(.subtitle)
        
      Spacer()
      
      DiscordAuthButton(action: { showDiscordLogin = true })
        .padding(.bottom, 8)
    }
    .padding()
    .sheet(isPresented: $showDiscordLogin) {
      NavigationView {
        DiscordAuthWebView(
          url: URL(string: "https://discord.com/api/oauth2/authorize?client_id=1044527343076642816&redirect_uri=https%3A%2F%2Fgetmochi.co%2Fauth%2Fv1%2Fcallback&response_type=token&scope=identify")!,
          token: $token,
          error: $error)
        .navigationTitle("Login with Discord")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
    .onChange(of: token) { accessToken in
      showDiscordLogin = false
      appStateManager.loginWithDiscord(accessToken: accessToken)
    }
    .onChange(of: error) { _ in
      showDiscordLogin = false
    }
  }
}

struct ConnectToDiscordView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectToDiscordView()
    }
}

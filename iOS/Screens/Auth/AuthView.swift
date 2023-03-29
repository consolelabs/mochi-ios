//
//  AuthView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 22/11/2022.
//

import SwiftUI
import WebKit
import AuthenticationServices
import OSLog

struct AuthView: View {
  @EnvironmentObject var appStateManager: AppStateManager
  
  @State private var showDiscordLogin: Bool = false
  @State private var token: String = ""
  @State private var error: String = ""
 
  private let logger = Logger(subsystem: "so.console.mochi", category: "AuthView")

  var body: some View {
    VStack {
      Image("icon")
        .resizable()
        .scaledToFill()
        .frame(width: 150, height: 150, alignment: .center)
        .padding(.vertical, 40)
     
      Text("Welcome to Mochi")
        .font(.system(.largeTitle, design: .rounded).weight(.bold))
        .foregroundColor(.title)
      
      Text("Give you complete control of your crypto.")
        .multilineTextAlignment(.center)
        .font(.system(.body, design: .rounded).weight(.medium))
        .foregroundColor(.subtitle)
        
      Spacer()
      
      DiscordAuthButton(action: { showDiscordLogin = true })
        .padding(.bottom, 8)
      
      SignInWithAppleButton(.continue) { request in
        request.requestedScopes = [.email, .fullName]
      } onCompletion: { result in
        switch result {
        case .success(let authResults):
          guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential else {
            return
          }
          appStateManager.loginWithApple(userId: credential.user,
                                         email: credential.email ?? "NA",
                                         name: credential.fullName?.givenName ?? "NA")
        case .failure(let error):
          logger.error("Authenticate with Apple failed, error: \(error.localizedDescription)")
        }
      }
      .frame(height: 50)
    }
    .padding()
    .onChange(of: error) { _ in
      showDiscordLogin = false
    }
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView()
  }
}


//
//  LoginView.swift
//  Mochi
//
//  Created by Oliver Le on 27/01/2023.
//

import SwiftUI
import OSLog
import CryptoKit


struct LoginView: View {
  // MARK: - State
  @Environment(\.openURL) var openURL
  @EnvironmentObject var appStateManager: AppStateManager
  
  @State private var email = ""
  @State private var showDiscordLogin: Bool = false
  @State private var token: String = ""
  @State private var error: String = ""
  
  @StateObject private var vm: LoginViewModel = LoginViewModel()
  
  private let logger = Logger(subsystem: "so.console.mochi", category: "LoginView")
  private let discordAuthURL = "https://discord.com/api/oauth2/authorize?client_id=1044527343076642816&redirect_uri=https%3A%2F%2Fgetmochi.co%2Fauth%2Fv1%2Fcallback&response_type=token&scope=identify"
  
  // MARK: - Body
  var body: some View {
    ZStack {
        Theme.gray
          .ignoresSafeArea()
        ScrollView {
          Spacer(minLength: 88)
          VStack(spacing: 16) {
            Text("Log in")
              .font(.boldSora(size: 32))
            Spacer(minLength: 42)
            divider("Sign in with a mobile wallet app")
            walletLoginButtonGroup
//              .disabled(true)
            divider("Or connect with verified social links")
            socialLoginButtonGroup
          }
          .padding(.horizontal, 35)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            navbar
          }
        }
      }
    .sheet(isPresented: $showDiscordLogin) {
      NavigationView {
        DiscordAuthWebView(
          url: URL(string: discordAuthURL)!,
          token: $token,
          error: $error)
        .navigationTitle("Login with Discord")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
    .onOpenURL { url in
      vm.onOpenURL(url: url)
    }
    .onChange(of: token) { accessToken in
      DispatchQueue.main.async {
        showDiscordLogin = false
        appStateManager.loginWithDiscord(accessToken: accessToken)
      }
    }
    .onChange(of: error) { _ in
      DispatchQueue.main.async {
        showDiscordLogin = false
      }
    }
    .onReceive(vm.accessToken) { token in
      appStateManager.login(accessToken: token)
    }
    .onReceive(vm.openURL) { url in
      openURL(url)
    }
  }
  
 
  
  // MARK: - Navbar
  private var navbar: some View {
    HStack {
      HStack {
        Asset.avatar
          .frame(width: 40, height: 40)
          .clipShape(Circle())
        Text("MOCHI")
          .font(.interBlack(size: 16))
          .foregroundColor(Theme.text1)
        +
        Text(".")
          .font(.interBlack(size: 16))
          .foregroundColor(Theme.primary)
      }
      Spacer()
      AboutMenuView()
    }
  }
  
  // MARK: - Login buttons group
  
  private var walletLoginButtonGroup: some View {
    VStack(spacing: 12) {
      walletLoginButton(logo: Asset.metamask, name: "Metamask") {
        vm.loginWithMetamask()
      }
      walletLoginButton(logo: Asset.phantom, name: "Phantom") {
        vm.loginWithPhantom()
      }
    }
  }
    

  
  private var socialLoginButtonGroup: some View {
    VStack(spacing: 12) {
      HStack(spacing: 12) {
        loginIconButton(icon: Asset.discord, name: "Discord", action: { showDiscordLogin = true })
        loginIconButton(icon: Image(systemName: "applelogo"), name: "Apple", action: {})
      }
//      HStack(spacing: 12) {
//        loginIconButton(icon: Asset.discord, name: "Discord", action: {})
//        loginIconButton(icon: Asset.telegram, name: "Telegram", action: {})
//      }
//      HStack(spacing: 12) {
//        loginIconButton(icon: Asset.twitter, name: "Twitter", action: {})
//        loginIconButton(icon: Asset.google, name: "Google", action: {})
//      }
//      HStack(spacing: 12) {
//        loginIconButton(icon: Image(systemName: "applelogo"), name: "Apple", action: {})
//        loginTextOnlyButton(name: "Another Email", action: {})
//      }
    }
  }
  
  // MARK: - Divider
  private func divider(_ label: String) -> some View {
    HStack(spacing: 16) {
      Rectangle()
        .frame(minWidth: 20, maxWidth: .infinity)
        .frame(height: 1)
        .foregroundColor(Theme.text5)
      Text(label)
        .font(.inter(size: 13))
        .foregroundColor(Theme.text4)
        .layoutPriority(1)
      Rectangle()
        .frame(minWidth: 20, maxWidth: .infinity)
        .frame(height: 1)
        .foregroundColor(Theme.text5)
    }
  }
  
  // MARK: - Email textfield
  private var emailTextfield: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("YOUR EMAIL")
        .foregroundColor(Theme.text4)
        .font(.interSemiBold(size: 10))
      TextField("hello@email.com", text: $email)
        .keyboardType(.emailAddress)
        .autocorrectionDisabled()
        .autocapitalization(.none)
        .foregroundColor(Theme.text1)
        .font(.interSemiBold(size: 16))
        .textFieldStyle(.roundedBorder)
    }
  }
  
  // MARK: - Login button
  private var loginButton: some View {
    Button(action: {}) {
      Text("Login")
        .font(.interSemiBold(size: 16))
        .foregroundColor(Theme.gray)
        .padding(.horizontal, 16)
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).foregroundColor(Theme.primary))
    }
    .buttonStyle(.plain)
  }
  
  // MARK: - Button Builder
  private func walletLoginButton(logo: Image, name: String, action: @escaping () -> Void) -> some View {
    return Button(action: action) {
      HStack {
        Text(name)
          .foregroundColor(Theme.text1)
          .font(.interSemiBold(size: 16))
        Spacer()
        logo
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 32, height: 32)
      }
      .padding()
      .frame(maxWidth: .infinity)
      .frame(height: 48)
      .background(
        RoundedRectangle(cornerRadius: 8).foregroundColor(.white)
          .shadow(color: Color.black.opacity(0.2), radius: 2.65, y: 0.88)
      )
    }
    .buttonStyle(.plain)
  }
  
  private func loginIconButton(icon: Image, name: String, action: @escaping () -> Void) -> some View {
    return Button(action: action) {
      HStack(spacing: 8) {
        icon
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 16, height: 16)
        Text(name)
          .foregroundColor(Theme.text1)
          .font(.interSemiBold(size: 16))
      }
      .frame(minWidth: 154, maxWidth: .infinity)
      .frame(height: 44)
      .background(
        RoundedRectangle(cornerRadius: 8).foregroundColor(.white)
          .shadow(color: Color.black.opacity(0.2), radius: 2.65, y: 0.88)
      )
    }
    .buttonStyle(.plain)
  }
  
  
  private func loginTextOnlyButton(name: String, action: @escaping () -> Void) -> some View {
    return Button(action: action) {
      Text(name)
        .foregroundColor(Theme.text1)
        .font(.interSemiBold(size: 16))
        .frame(minWidth: 154, maxWidth: .infinity)
        .frame(height: 44)
        .background(
          RoundedRectangle(cornerRadius: 8).foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.2), radius: 2.65, y: 0.88)
        )
    }
    .buttonStyle(.plain)
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}

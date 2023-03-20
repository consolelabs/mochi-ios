//
//  ContentView.swift
//  Mochi
//
//  Created by Oliver Le on 19/01/2023.
//

import SwiftUI

struct OnboardingView: View {
  
  // MARK: - State
  @State private var ens: String = ""
  @State private var showLogin: Bool = false
  // MARK: - Body
  var body: some View {
    NavigationView {
      ZStack {
        Theme.gray
          .ignoresSafeArea()
        ScrollView {
          VStack {
            heroContent
              .padding(.top, 20)
              .padding(.bottom, 49)
            illustrate
          }
          .padding(.horizontal)
         
          // Trick to navigate to login view
          NavigationLink(destination: LoginView(), isActive: $showLogin) {
            Color.clear
          }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
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
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
              Button(action: { showLogin = true }) {
                Text("Log in")
                  .font(.interSemiBold(size: 16))
                  .foregroundColor(Theme.gray)
                  .padding(.horizontal, 16)
                  .frame(height: 40)
                  .background(RoundedRectangle(cornerRadius: 12, style: .continuous).foregroundColor(Theme.text1))
              }
              .buttonStyle(.plain)
              Button {} label: {
                Image(systemName: "ellipsis")
                  .font(.system(size: 11))
                  .foregroundColor(Theme.text1)
                  .frame(width: 32, height: 32)
                  .background(Circle().foregroundColor(Theme.text5))
              }
              .buttonStyle(.plain)
            }
          }
        }
      }
    }
  }
  
  // MARK: - Navbar
  private var navbar: some View {
    HStack {
      Spacer()
    }
  }
  
  // MARK: - Hero
  private var heroContent: some View {
    VStack(alignment: .leading, spacing: 16) {
      Group {
        Text("Bring ")
        +
        Text("Web3 ")
          .foregroundColor(Color(red: 0.95, green: 0.48, blue: 0.46))
        +
        Text("universe to your ")
        +
        Text("Discord ")
          .foregroundColor(Color(red: 0.41, green: 0.46, blue: 0.93))
        +
        Text("Server")
      }
      .font(.boldSora(size: 46))
      .foregroundColor(Theme.text1)
      
      Text("Smooth onboarding, automated moderation, crypto ticker, NFT rarity ranking, and much more.")
        .font(.inter(size: 18))
        .lineSpacing(8)
        .foregroundColor(Theme.text2)
      
      HStack {
        TextField("mochi.gg/ens", text: $ens)
          .autocapitalization(.none)
          .autocorrectionDisabled()
          .font(.interSemiBold(size: 16))
          .frame(height: 40)
          .textFieldStyle(.roundedBorder)
        Button(action: {}) {
          Text("Connect")
            .font(.interSemiBold(size: 16))
            .foregroundColor(Theme.gray)
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).foregroundColor(Theme.primary))
        }
        .buttonStyle(.plain)
        
      }
    }
  }
  
  private var illustrate: some View {
    Asset.rocket
      .resizable()
      .aspectRatio(1.67, contentMode: .fit)
      .padding(.vertical, 7)
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      OnboardingView()
        .previewDisplayName("iPhone 14 Pro")
      
      OnboardingView()
        .previewDisplayName("iPhone SE2")
        .previewDevice("iPhone SE (3rd generation)")
    }
  }
}

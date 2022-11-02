//
//  OnboardingView.swift
//  Bitsfi
//
//  Created by Oliver Le on 08/06/2022.
//

import SwiftUI

struct OnboardingView: View {
  var body: some View {
    NavigationView {
      VStack {
        OnboardingPageView()
        Button(action: {
//          appState.createWallet()
        }) {
          Text("Create a new wallet")
            .fontWeight(.semibold)
        }
        .buttonStyle(.primaryExpanded)
        NavigationLink {
          ImportWalletListView()
        } label: {
          Text("I already have a wallet")
            .foregroundColor(.appPrimary)
            .fontWeight(.medium)
        }
      }
      .padding()
    }
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingView()
  }
}

struct OnboardingContentView: View {
  let imageName: String
  let title: String
  let subtitle: String
  
  var body: some View {
    VStack {
      RoundedRectangle(cornerRadius: 16)
        .frame(width: 200, height: 200, alignment: .center)
        .foregroundColor(.appPrimary)
      
      Text(title)
        .foregroundColor(.title)
        .font(.title)
        .fontWeight(.medium)
      
      Text(subtitle)
        .foregroundColor(.subtitle)
        .font(.subheadline)
    }
  }
}

struct OnboardingPageView: View {
  var body: some View {
    TabView {
      OnboardingContentView(imageName: "", title: "Private and secure", subtitle: "Private keys never leave your device.")
      OnboardingContentView(imageName: "", title: "All assets in one place", subtitle: "View and store your assets seamlessly.")
      OnboardingContentView(imageName: "", title: "Trade assets", subtitle: "Trade your assets anonymously.")
    }
    .tabViewStyle(.page)
    .indexViewStyle(.page(backgroundDisplayMode: .always))
  }
}

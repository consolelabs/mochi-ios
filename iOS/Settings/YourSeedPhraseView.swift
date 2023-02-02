//
//  YourSeedPhraseView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 22/07/2022.
//

import SwiftUI

class YourSeedPhraseViewModel: ObservableObject {
  private let walletManager = WalletManagerImpl(
    localStorage: LocalStorage(),
    keychainService: KeychainServiceImpl()
  )
  
  @Published var secretPhrase: [String] = []
  
  func fetchSecretPhrase() {
    do {
      let mnemonics = try walletManager.getCurrentWalletMnemonics()
      self.secretPhrase = mnemonics.components(separatedBy: .whitespaces)
    } catch {
      print(error)
    }
  }
}

struct YourSeedPhraseView: View {
  @StateObject private var vm = YourSeedPhraseViewModel()
  
  var body: some View {
    ScrollView {
      VStack {
        Text("Your secret phrase")
          .foregroundColor(.title)
          .font(.title2.weight(.semibold))
        
        Text("**These words are the keys to your wallet!** Write them down or save them in your password manager")
          .foregroundColor(.subtitle)
          .multilineTextAlignment(.center)
          .padding(.bottom)
        
        Button(action: {}) {
          Label("Copy to clipboard", systemImage: "square.on.square")
            .font(.body.weight(.semibold))
        }
        
        SecretPhraseView(words: vm.secretPhrase)
          .padding()
        
        VStack(spacing: 8) {
          Text("Do not share your secret phrase!")
            .font(.body.weight(.medium))
          
          Text("If someone has your secret phrase, they will have full control of your wallet.")
            .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.neutral1)
        .cornerRadius(4)
        .padding(.bottom)
      }
      .padding()
    }
    .onAppear {
      vm.fetchSecretPhrase()
    }
  }
}

struct YourSeedPhraseView_Previews: PreviewProvider {
  static var previews: some View {
    YourSeedPhraseView()
  }
}

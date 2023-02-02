//
//  BackupWalletManuallyView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 22/07/2022.
//

import SwiftUI

class BackupWalletManuallyViewModel: ObservableObject {
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

struct BackupWalletManuallyView: View {
  @StateObject var vm = BackupWalletManuallyViewModel()
  
  let didBackup: () -> Void
  
  init(didBackup: @escaping () -> Void = {}) {
    self.didBackup = didBackup
  }
  
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
        
        Button {
          didBackup()
        } label: {
          HStack {
            Image(systemName: "checkmark.circle.fill")
            Text("I've saved these words")
          }
          .font(.body.weight(.semibold))
        }
        .buttonStyle(.primaryExpanded)
      }
      .padding()
    }
    .onAppear {
      vm.fetchSecretPhrase()
    }
  }
}

struct BackupWalletManuallyView_Previews: PreviewProvider {
  static var previews: some View {
    BackupWalletManuallyView()
  }
}

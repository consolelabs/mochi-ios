//
//  BackupWalletContainerView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 22/07/2022.
//

import SwiftUI

class BackupWalletContainerViewModel: ObservableObject {
  enum ScreenState {
    case isBackupIcloud
    case isBackupManually
    case notBackup
  }
  
  @Published var currentWallet: WalletInfo? = nil
  @Published var screenState: ScreenState = .notBackup
  
  var didBackupToIcloud: Bool {
    currentWallet?.isBackupIcloud ?? false
  }
  
  var didBackupManually: Bool {
    currentWallet?.isBackupManually ?? false
  }
  
  private let walletManager = WalletManagerImpl(
    localStorage: LocalStorage(),
    keychainService: KeychainServiceImpl()
  )
  
  func fetchCurrentWallet() {
    self.currentWallet = walletManager.getCurrentWallet()
    if let currentWallet = currentWallet {
      guard currentWallet.isBackupIcloud || currentWallet.isBackupManually else {
        screenState = .notBackup
        return
      }
      self.screenState = currentWallet.isBackupIcloud ? .isBackupIcloud : .isBackupManually
    }
  }
  
  func backupWalletToIcloud() {
    do {
      try walletManager.backupCurrentWalletToIcloud()
    } catch {
      // TODO: handle error properly
      print(error)
    }
    screenState = .isBackupIcloud
  }
  
  func backupWalletManually() {
    do {
      try walletManager.backupCurrentWalletManually()
    } catch {
      // TODO: handle error properly
      print(error)
    }
    screenState = .isBackupManually
  }
}

struct BackupWalletContainerView: View {
  
  @State private var showBackupToIcloudView: Bool = false
  @State private var showBackupManuallyView: Bool = false
  @State private var showYourSecretPhraseView: Bool = false
 
  @StateObject private var vm = BackupWalletContainerViewModel()

  var body: some View {
    VStack {
      switch vm.screenState {
      case .notBackup:
        notBackupView
      case .isBackupManually:
        backupManuallyView
      case .isBackupIcloud:
        backupIcloudView
      }
    }
    .sheet(isPresented: $showBackupManuallyView, content: {
      BackupWalletManuallyView {
        vm.backupWalletManually()
        self.showBackupManuallyView = false
      }
    })
    .sheet(isPresented: $showYourSecretPhraseView, content: {
      YourSeedPhraseView()
    })
    .padding()
    .onAppear(perform: {
      vm.fetchCurrentWallet()
    })
    .navigationTitle("Backup")
  }
  
  var notBackupView: some View {
    VStack {
      Spacer()
      Image(systemName: "exclamationmark.icloud.fill")
        .foregroundColor(.white)
        .font(.title)
        .frame(width: 60, height: 60, alignment: .center)
        .background(Color.orange)
        .clipShape(RoundedRectangle(cornerRadius: 16))
      
      Text("Back up your wallet")
        .font(.title2.bold())
        .foregroundColor(.title)
      
      Text("Don't risk your money! Back up your wallet so you can recover it if you lose this device.")
        .foregroundColor(.subtitle)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
      
      Spacer()
      
      Button(action: {
        vm.backupWalletToIcloud()
      }) {
        Text("Back up to iCloud")
          .fontWeight(.semibold)
      }
      .buttonStyle(.primaryExpanded)
      
      Button(action: {
        showBackupManuallyView.toggle()
      }) {
        Text("Backup manually")
          .fontWeight(.medium)
      }
    }
  }
  
  var backupManuallyView: some View {
    VStack {
      Spacer()
      Image(systemName: "checkmark.icloud.fill")
        .foregroundColor(.white)
        .font(.title)
        .frame(width:60, height: 60, alignment: .center)
        .background(Color.green)
        .clipShape(RoundedRectangle(cornerRadius: 16))
      
      Text("Your wallet is backed up")
        .font(.title2.bold())
        .foregroundColor(.title)
      
      Text("If you lose this device, you can restore your wallet with the secret phrase you saved.")
        .foregroundColor(.subtitle)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
      
      Spacer()
      
      Button(action: { self.showYourSecretPhraseView.toggle() }) {
        Text("View secret phrase")
          .fontWeight(.semibold)
      }
      .buttonStyle(.primaryExpanded)
      
      Button(action: { vm.backupWalletToIcloud() }) {
        HStack {
          Image(systemName: "lock.icloud.fill")
          Text("Back up to iCloud")
        }
        .font(.body.weight(.semibold))
      }
    }
  }
  
  var backupIcloudView: some View {
    VStack {
      Spacer()
      Image(systemName: "checkmark.icloud.fill")
        .foregroundColor(.white)
        .font(.largeTitle)
        .frame(width: 60, height: 60, alignment: .center)
        .background(Color.green)
        .clipShape(RoundedRectangle(cornerRadius: 16))
      
      Text("Your wallet is backed up")
        .font(.title2.bold())
        .foregroundColor(.title)
      
      Text("If you lose this device, you can recover your encrypted wallet back up from iCloud.")
        .foregroundColor(.subtitle)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
      
      Spacer()
      
      Button(action: { self.showYourSecretPhraseView.toggle() }) {
        Text("View secret phrase")
          .fontWeight(.semibold)
      }
      .buttonStyle(.primaryExpanded)
    }
  }

}

struct BackupWalletView_Previews: PreviewProvider {
  static var previews: some View {
    BackupWalletContainerView()
  }
}

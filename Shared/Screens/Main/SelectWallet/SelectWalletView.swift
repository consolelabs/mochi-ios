//
//  SelectWalletView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 26/07/2022.
//

import SwiftUI

class SelectWalletViewModel: ObservableObject {
  @Published var isEditMode: Bool = false
  @Published var items: [SelectWalletItemViewModel] = []
  @Published var isLoading: Bool = false
  @Published var currentWallet: WalletInfo? = nil
  @Published var isWalletEmpty: Bool = false
  
  private let walletManager: WalletManager
  
  init(walletManager: WalletManager) {
    self.walletManager = walletManager
  }
 
  func onAppear() {
      fetchItems()
  }
  
  func select(wallet: SelectWalletItemViewModel) {
    let wallet = WalletInfo(id: wallet.id,
                            address: wallet.address,
                            name: wallet.name,
                            emoticon: wallet.emoticon,
                            type: .hd,
                            isBackupManually: true,
                            isBackupIcloud: false)
    walletManager.setCurrentWallet(wallet: wallet)
    self.items = self.items.map { item in
      var item = item
      item.isSelected = item.id == wallet.id
      return item
    }
    self.currentWallet = wallet
  }
  
  func createNewWallet() {
    isLoading = true
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try self.walletManager.addNewWalletFromCurrentMnemonics()
        DispatchQueue.main.async {
          self.fetchItems()
          self.isLoading = false
        }
      } catch {
        // TODO: handle error
        print(error)
        DispatchQueue.main.async {
          self.isLoading = false
        }
      }
    }
  }
  
  func deleteWallet(item: SelectWalletItemViewModel) {
    let localStorage = LocalStorage()
    localStorage.wallets = localStorage.wallets.filter { $0.id != item.id}
    if item.isSelected {
      localStorage.currentWallet = localStorage.wallets.first
    }
    fetchItems()
    isWalletEmpty = items.isEmpty
  }
  
  private func fetchItems() {
    let wallets = walletManager.getWallets()
    let currentWallet = walletManager.getCurrentWallet()
    
    items = wallets.map { info -> SelectWalletItemViewModel in
      return SelectWalletItemViewModel(
        id: info.id,
        address: info.address,
        name: info.name,
        emoticon: info.emoticon,
        isSelected: currentWallet?.id == info.id
      )
    }
  }
}

struct SelectWalletView: View {
  
  @StateObject private var vm = SelectWalletViewModel(
    walletManager: WalletManagerImpl(localStorage: LocalStorage(), keychainService: KeychainServiceImpl())
  )
  
  @EnvironmentObject var appState: AppState
  
  var body: some View {
    NavigationView {
      VStack {
        if vm.isLoading {
          ProgressView()
        } else {
          VStack {
            ScrollViewReader { proxy in
              List {
                ForEach(vm.items) { item in
                  VStack {
                    if vm.isEditMode {
                      EditSelectWalletListItemView(itemVM: item) {
                        vm.deleteWallet(item: item)
                      }
                    } else {
                      Button(action: { vm.select(wallet: item) }) {
                        SelectWalletListItemView(itemVM: item)
                      }
                    }
                  }
                  .id(item.id)
                  .listRowSeparator(.hidden)
                }
                .padding(.vertical, 4)
              }
              .listStyle(PlainListStyle())
              .onChange(of: vm.items.count) { _ in
                withAnimation {
                  proxy.scrollTo(vm.items.last?.id)
                }
              }
            }
            
            VStack(spacing: 16) {
              Button(action: { vm.createNewWallet() }) {
                HStack {
                  Label("Create a new wallet", systemImage: "plus.circle.fill")
                  Spacer()
                }
              }
              
              Button(action: {  }) {
                HStack {
                  Label("Add an existing wallet", systemImage: "arrow.uturn.down.circle.fill")
                  Spacer()
                }
              }
            }
            .padding()
            .disabled(vm.isEditMode)
          }
        }
      }
      .navigationTitle("Wallets")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(vm.isEditMode ? "Done" : "Edit") {
            vm.isEditMode.toggle()
          }
        }
      }
      .onChange(of: vm.currentWallet) { newValue in
        if let wallet = newValue {
          appState.updateCurrentWallet(wallet: wallet)
        }
      }
      .onChange(of: vm.isWalletEmpty) { walletIsEmpty in
        if walletIsEmpty {
          appState.deleteWallet()
          appState.showSelectWallet = false
        }
      }
      .onAppear {
        vm.onAppear()
      }
    }
  }
}

struct SelectWalletView_Previews: PreviewProvider {
  static var previews: some View {
    SelectWalletView()
      .previewLayout(.fixed(width: 400, height: 400))
  }
}

struct SelectWalletItemViewModel: Identifiable, Equatable {
  let id: String
  let address: String
  var name: String
  var emoticon: String
  var isSelected: Bool
  
  init(
    id: String = UUID().uuidString,
    address: String,
    name: String,
    emoticon: String,
    isSelected: Bool
  ) {
    self.id = id
    self.address = address
    self.name = name
    self.emoticon = emoticon
    self.isSelected = isSelected
  }
}

struct SelectWalletListItemView: View {
  let itemVM: SelectWalletItemViewModel
  
  var body: some View {
    HStack {
      Text(itemVM.emoticon)
        .frame(width: 35, height: 35)
        .background(Color.yellow)
        .clipShape(Circle())
      
      VStack(alignment: .leading) {
        Text(itemVM.name)
          .font(.headline)
          .foregroundColor(.title)
        Text(itemVM.address)
          .lineLimit(1)
          .truncationMode(.middle)
          .font(.footnote)
          .foregroundColor(.subtitle)
          .frame(width: 100, alignment: .leading)
      }
      
      Spacer()
        
      if itemVM.isSelected {
        Image(systemName: "checkmark.circle.fill")
          .resizable()
          .foregroundColor(.appPrimary)
          .frame(width: 16, height: 16)
      }
    }
  }
}

struct EditSelectWalletListItemView: View {
  let itemVM: SelectWalletItemViewModel
  let deleteWallet: () -> Void
  
  init(itemVM: SelectWalletItemViewModel, deleteWallet: @escaping () -> Void = {}) {
    self.itemVM = itemVM
    self.deleteWallet = deleteWallet
  }
  
  @State private var showingOptions = false
  
  var body: some View {
    HStack {
      Text(itemVM.emoticon)
        .frame(width: 35, height: 35)
        .background(Color.yellow)
        .clipShape(Circle())
      
      VStack(alignment: .leading) {
        Text(itemVM.name)
          .font(.headline)
          .foregroundColor(.title)
        Text(itemVM.address)
          .lineLimit(1)
          .truncationMode(.middle)
          .font(.footnote)
          .foregroundColor(.subtitle)
          .frame(width: 100, alignment: .leading)
      }
      
      Spacer()
     
      Button(action: { showingOptions.toggle() }) {
        Image(systemName: "ellipsis.circle")
          .resizable()
          .foregroundColor(.appPrimary)
          .frame(width: 16, height: 16)
      }
    }
    .confirmationDialog("Edit Wallet", isPresented: $showingOptions) {
      Button("Edit Wallet") {
      }
      
      Button("Delete Wallet", role: .destructive) {
        deleteWallet()
      }
    }
  }
}

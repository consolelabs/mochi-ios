//
//  ImportWalletView.swift
//  Bitsfi
//
//  Created by Oliver Le on 09/06/2022.
//

import SwiftUI

struct ImportWalletView: View {
  enum ImportType: String, CaseIterable, Identifiable {
    case phrase, privateKey, address
    var id: Self { self }
  }
  
  private let chain: Chain
  @FocusState private var nameInFocus: Bool
  @State private var walletName: String = "My Wallet"
  @State private var importType: ImportType = .phrase
  @State private var phrase: String = ""
  @State private var privateKey: String = ""
  @State private var address: String = ""
  
  init(chain: Chain) {
    self.chain = chain
  }
  
  var body: some View {
    VStack {
      Form {
        Section {
          VStack(alignment: .leading) {
            TextField(text: $walletName, prompt: Text("Required")) {
              Text("My Wallet")
            }
            .focused($nameInFocus)
          }
        } header: {
          Text("Wallet name")
        }
        
        Section {
          Picker("Import From", selection: $importType) {
            Text("Phrase").tag(ImportType.phrase)
            Text("Private Key").tag(ImportType.privateKey)
            Text("Address").tag(ImportType.address)
          }
          .pickerStyle(.segmented)
          .background(.clear)
          
          switch importType {
          case .phrase:
            TextEditor(text: $phrase)
              .frame(height: 150)
          case .privateKey:
            TextEditor(text: $privateKey)
              .frame(height: 150)
          case .address:
            TextField("Address", text: $address)
          }
        } header: {
          Text("Import method")
        }
      }
      Button("Import wallet", action: {})
        .buttonStyle(.primaryExpanded)
        .padding()
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
        self.nameInFocus = true
      }
    }
    .navigationTitle("Import \(chain.name)")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct ImportWalletView_Previews: PreviewProvider {
  static var previews: some View {
    ImportWalletView(chain: .init(id: "ethereum", name: "Ethereum"))
  }
}

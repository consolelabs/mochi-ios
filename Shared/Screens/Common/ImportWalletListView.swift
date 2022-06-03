//
//  ImportWalletListView.swift
//  Bitsfi
//
//  Created by Oliver Le on 08/06/2022.
//

import SwiftUI
import CachedAsyncImage

struct Chain {
  let id: String
  let name: String
  var imageUrl: String {
    return "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/\(id)/info/logo.png"
  }
}

let chainList: [Chain] = [
  .init(id: "ethereum", name: "Ethereum"),
  .init(id: "smartchain", name: "BNB Smart Chain"),
  .init(id: "avalanchec", name: "Avalanche"),
  .init(id: "fantom", name: "Fantom")
]

struct ImportWalletListView: View {
  var body: some View {
    List {
      ForEach(chainList, id: \.name) { chain in
        NavigationLink {
          ImportWalletView(chain: chain)
        } label: {
          HStack {
            CachedAsyncImage(url: URL(string: chain.imageUrl)) { image in
              image
                .resizable()
                .clipShape(Circle())
            } placeholder: {
              Circle()
                .foregroundColor(.gray)
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40, alignment: .center)
            Text(chain.name)
          }
        }
      }
    }
    .navigationTitle("Import")
  }
}

struct ImportWalletListView_Previews: PreviewProvider {
    static var previews: some View {
        ImportWalletListView()
    }
}

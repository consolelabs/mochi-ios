//
//  WalletItemRow.swift
//  Mochi
//
//  Created by Oliver Le on 28/01/2023.
//

import SwiftUI

struct WalletItem {
  let id: String
  let isEvm: Bool
  let address: String
  var ens: String
  let coin: Coin
}

extension WalletItem {
  static var mock: Self {
    return WalletItem(id: "0",
                      isEvm: true,
                      address: "0x5417A03667AbB6A059b3F174c1F67b1E83753046",
                      ens: "",
                      coin: Coin(id: "0", name: "ETH", symbol: "ETH", icon: "eth")
    )
  }
  
  static var mockWithENS: Self {
    return WalletItem(id: "0",
                      isEvm: true,
                      address: "0x5417A03667AbB6A059b3F174c1F67b1E83753046",
                      ens: "mochi.eth",
                      coin: Coin(id: "0", name: "ETH", symbol: "ETH", icon: "eth")
    )
  }
}

struct Coin {
  let id: String
  let name: String
  let symbol: String
  let icon: String
}

extension Coin {
  static var eth: Self {
    return Coin(id: "1", name: "Ethereum", symbol: "ETH", icon: "eth")
  }
  
  static var sol: Self {
    return Coin(id: "999", name: "Solana", symbol: "SOL", icon: "sol")
  }
}

struct WalletItemRow: View {
  // MARK: - State
  let item: WalletItem
  
  // MARK: - Body
  var body: some View {
    HStack(spacing: 8) {
      Image(item.coin.icon)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 32, height: 32)
        .clipShape(Circle())
      Text(item.coin.symbol.uppercased())
        .lineLimit(1)
        .foregroundColor(Theme.text1)
        .font(.inter(size: 12, weight: .bold))
      Text(item.address)
        .lineLimit(1)
        .truncationMode(.middle)
        .font(.interSemiBold(size: 16))
        .foregroundColor(Theme.text1)
        .frame(minWidth: 80, maxWidth: 130)
      Text(item.ens)
        .lineLimit(1)
        .font(.interSemiBold(size: 15))
        .foregroundColor(Theme.text4)
        .minimumScaleFactor(0.5)
      Spacer()
    }
    .padding(.vertical, 12)
    .padding(.trailing, 15)
    .frame(maxWidth: .infinity)
  }
}

struct WalletItemRow_Previews: PreviewProvider {
  static var previews: some View {
    WalletItemRow(item: .mockWithENS)
      .previewLayout(.sizeThatFits)
      .previewDisplayName("With ENS")
    
    WalletItemRow(item: .mock)
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Without ENS")
  }
}

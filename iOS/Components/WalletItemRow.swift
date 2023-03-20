//
//  WalletItemRow.swift
//  Mochi
//
//  Created by Oliver Le on 28/01/2023.
//

import SwiftUI

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
                .frame(width: 48, alignment: .leading)
            Spacer()
            Text(item.address)
                .lineLimit(1)
                .truncationMode(.middle)
                .font(.interSemiBold(size: 16))
                .foregroundColor(Theme.text1)
                .frame(width: 100)
            Text(item.ens)
                .lineLimit(1)
                .font(.interSemiBold(size: 15))
                .foregroundColor(Theme.text4)
                .layoutPriority(1)
        }
        .padding(.vertical, 12)
        .padding(.trailing, 15)
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
//
//  NFTItemRow.swift
//  Mochi
//
//  Created by Oliver Le on 29/01/2023.
//

import SwiftUI

struct NFTItem {
    let id: String
    let name: String
    let image: String
    let chain: Chain
    let nfts: [NFT]
}

extension NFTItem {
    static var mock: Self {
        let coin = Coin(id: UUID().uuidString, name: "ETH", symbol: "ETH", icon: "ETH")
        let chain = Chain(id: 1, name: "ETH", coin: coin)
        let nfts = [
            NFT(id: 0, name: "Ducky #1", image: "ducky"),
            NFT(id: 1, name: "Ducky #2", image: "ducky"),
            NFT(id: 2, name: "Ducky #3", image: "ducky"),
            NFT(id: 3, name: "Ducky #4", image: "ducky"),
            NFT(id: 4, name: "Ducky #5", image: "ducky"),
        ]
        return Self(id: UUID().uuidString,
                    name: "Crypto Duckies",
                    image: "",
                    chain: chain,
                    nfts: nfts)
    }
}

struct Chain {
    let id: Int
    let name: String
    let coin: Coin
}

struct NFT: Identifiable {
    let id: Int
    let name: String
    let image: String
}

struct NFTItemRow: View {
    // MARK: - State
    @State var isExpanded: Bool = false
    
    let item: NFTItem
   
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            mainRow
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            if isExpanded {
                expandedContent
                    .animation(.none, value: isExpanded)
            }
        }
    }
    
    // MARK: - Main row
    var mainRow: some View {
        HStack(spacing: 8) {
            Image("avatar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            Text(item.name)
                .lineLimit(1)
                .font(.interSemiBold(size: 16))
                .foregroundColor(Theme.text1)
                .layoutPriority(1)
            Spacer()
            Image("avatar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            HStack(spacing: 0) {
                Text("\(item.nfts.count)")
                    .lineLimit(1)
                    .font(.interSemiBold(size: 15))
                    .foregroundColor(Theme.text4)
                Asset.arrowRight
                    .resizable()
                    .frame(width: 24, height: 24)
                    .rotationEffect(Angle(degrees: isExpanded ? 90 : 0))
            }
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Expanded content
    var expandedContent: some View {
        let columns = [
            GridItem(.flexible(minimum: 50, maximum: 100)),
            GridItem(.flexible(minimum: 50, maximum: 100)),
            GridItem(.flexible(minimum: 50, maximum: 100)),
        ]
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(item.nfts) { nft in
                Image("profile_pic")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .background(Theme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .circular))
            }
        }
    }
}

struct NFTItemRow_Previews: PreviewProvider {
    static var previews: some View {
        NFTItemRow(isExpanded: false,
                   item: .mock)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Collapsed")
        
        NFTItemRow(isExpanded: true,
                   item: .mock)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Expanded")
    }
}

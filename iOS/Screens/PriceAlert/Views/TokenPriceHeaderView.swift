//
//  TokenPriceHeaderView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 05/04/2023.
//

import SwiftUI

struct TokenPriceHeaderData: Identifiable {
  let id: String
  let tokenPair: TokenPair
  let pricingData: TokenPairPricingData?
}

extension TokenPriceHeaderData {
  static var mock: Self {
    return TokenPriceHeaderData(
      id: UUID().uuidString,
      tokenPair: TokenPair(left: "ETH", right: "USDT"),
      pricingData: TokenPairPricingData(
        name: "eth/usdt",
        currentValue: "1868.04",
        currentUsdValue: "$1868.04",
        h24PriceChangePercentage: "12.4%",
        is24hPriceUp: true)
    )
  }
}

struct TokenPriceHeaderView: View {
  let data: TokenPriceHeaderData
  
  var body: some View {
    HStack(spacing: 16) {
      Text(data.tokenPair.left)
        .font(.inter(size: 15, weight: .bold))
        .foregroundColor(Theme.text1)
      +
      Text("/\(data.tokenPair.right)")
        .font(.inter(size: 15, weight: .medium))
        .foregroundColor(Theme.text3)
      
      Spacer()
      
      if let currentValue = data.pricingData?.currentValue {
        Text(currentValue)
          .font(.interSemiBold(size: 15))
          .foregroundColor(Theme.text1)
      }
      
      HStack(spacing: 2) {
        if let currentUsdValue = data.pricingData?.currentUsdValue {
          Text(currentUsdValue)
            .font(.interSemiBold(size: 11))
            .foregroundColor(Theme.text3)
        }
        
        if let is24hPriceUp = data.pricingData?.is24hPriceUp {
          HStack(spacing: 0) {
            if is24hPriceUp {
              Asset.increase
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 13, height: 13)
            } else {
              Asset.decrease
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 13, height: 13)
            }
            
            if let h24PriceChangePercentage = data.pricingData?.h24PriceChangePercentage {
              Text(h24PriceChangePercentage)
                .font(.interSemiBold(size: 11))
                .foregroundColor(is24hPriceUp ? Theme.green2 : Theme.red)
            }
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
  }
}

struct TokenPriceHeaderView_Previews: PreviewProvider {
    static var previews: some View {
      TokenPriceHeaderView(data: .mock)
        .previewLayout(.sizeThatFits)
    }
}

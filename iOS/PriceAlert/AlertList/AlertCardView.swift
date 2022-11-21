//
//  AlertCardView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 18/11/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct AlertCardView: View {
  let alert: AlertPresenter
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        WebImage(url: URL(string: alert.image))
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 4))
          .frame(width: 16, height: 16)
        
        Text(alert.symbol.uppercased())
        
        Spacer()
        
        Image(systemName: alert.isEnable ? "bell.fill" : "bell.slash.fill")
      }
      .foregroundColor(Color.title)
      .font(.system(.headline, design: .rounded).weight(.semibold))
      .font(.headline)
      
      VStack(alignment: .leading) {
        HStack(spacing: 2) {
          Image(systemName: alert.trendSymbolName)
          Text(alert.trend)
        }
        .font(.system(.body, design: .rounded))
        
        Text(alert.price)
          .font(.system(.title2, design: .rounded).weight(.semibold))
      }
      .foregroundColor(alert.trendColor)
    }
  }
}

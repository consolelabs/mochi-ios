//
//  WatchlistView.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct WatchlistView: View {
  @ObservedObject var vm: WatchlistViewModel
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""

  var body: some View {
    NavigationView {
      List(vm.data, id: \.id) { item in
        GeometryReader { reader in
          HStack {
            HStack {
              WebImage(url: URL(string: item.image))
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(width: 20, height: 20)
              
              VStack(alignment: .leading) {
                Text(item.symbol)
                  .font(.system(size: 14))
                  .bold()
                Text(item.name)
                  .font(.system(size: 11))
              }
            }
            .frame(width: reader.size.width / 3, alignment: .leading)
            
            // Sparkline
            if !item.sparklineIn7d.price.isEmpty {
              SparklineView(prices: item.sparklineIn7d.price, color: item.priceChangePercentage24hColor)
                .frame(width: 80)
            } else {
              Color.clear
                .frame(width: 80)
            }
            
            VStack(alignment: .trailing) {
              Text(item.currentPrice)
                .bold()
                .font(.system(size: 14))
              
              Text(item.priceChangePercentage24h)
                .font(.system(size: 11))
                .foregroundColor(item.priceChangePercentage24hColor)
            }
            .frame(width: reader.size.width / 3, alignment: .trailing)
          }
        }
        .padding()
      }
      .listStyle(PlainListStyle())
      .navigationTitle("Watchlist")
      .toolbar {
        ToolbarItem {
          Button(action: {}) {
            Label("Setting", systemImage: "ellipsis.circle")
          }
        }
      }
    }
    .onChange(of: discordId) { newValue in
      Task {
        await vm.fetchWatchlist(with: newValue)
      }
    }
    .task {
      await vm.fetchWatchlist(with: discordId)
    }
  }
}

struct Watchlist_Previews: PreviewProvider {
  static var previews: some View {
    WatchlistView(vm: WatchlistViewModel(defiService: DefiServiceImpl()))
  }
}

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
  
  var watchlistRows: some View {
    ForEach(vm.data, id: \.id) { item in
      GeometryReader { reader in
        HStack {
          HStack {
            WebImage(url: URL(string: item.image))
              .resizable()
              .scaledToFit()
              .clipShape(RoundedRectangle(cornerRadius: 4))
              .frame(width: 25, height: 25)
            
            VStack(alignment: .leading) {
              Text(item.symbol)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.title)
              
              Text(item.name)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.subtitle)
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
              .font(.system(size: 14, weight: .bold, design: .rounded))
              .foregroundColor(.title)
            
            Text(item.priceChangePercentage24h)
              .font(.system(size: 12, weight: .semibold, design: .rounded))
              .foregroundColor(item.priceChangePercentage24hColor)
          }
          .frame(width: reader.size.width / 3, alignment: .trailing)
        }
      }
      .padding()
    }
    .onDelete { indexSet in
      vm.remove(at: indexSet)
    }
  }
  
  var searchCoinsRows: some View {
    ForEach(vm.searchCoins, id: \.presentedId) { item in
      HStack {
        Button {
          Task(priority: .high) {
            if item.isSelected {
              await vm.remove(symbol: item.id)
            } else {
              await vm.add(coinId: item.id)
            }
          }
        } label: {
          Image(systemName: item.isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
        }
        .buttonStyle(BorderlessButtonStyle())
        
        VStack(alignment: .leading) {
          Text(item.symbol.uppercased())
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.title)
          
          Text(item.name)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.subtitle)
        }
        Spacer()
      }
      .padding(.vertical, 4)
    }
  }
    
  var contentView: some View {
    NavigationView {
      List {
        if (vm.isSearching) {
          searchCoinsRows
        } else {
          watchlistRows
        }
      }
      .searchable(text: $vm.searchTerm)
      .autocorrectionDisabled()
      .textInputAutocapitalization(.never)
      .listStyle(PlainListStyle())
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          VStack(alignment: .leading) {
            Text("Watchlist")
              .font(.system(.title3, design: .rounded))
              .fontWeight(.bold)
            
            Text(Date().formatted(
              .dateTime
                .day().month()
            ))
            .font(.system(.title3, design: .rounded))
            .fontWeight(.bold)
            .foregroundColor(.subtitle)
            
            Spacer()
          }
        }
        ToolbarItem {
          EditButton()
        }
      }
    }
  }
  
  var body: some View {
    ZStack {
      if vm.isLoading {
        ActivityIndicator()
          .frame(width: 40, height: 40)
          .foregroundColor(.appPrimary)
      } else {
        contentView
      }
    }
    .onChange(of: discordId) { newValue in
      Task {
        await vm.fetchWatchlist()
      }
    }
    .task {
      await vm.fetchWatchlist()
    }
  }
}

struct Watchlist_Previews: PreviewProvider {
  static var previews: some View {
    WatchlistView(vm: WatchlistViewModel(defiService: DefiServiceMock()))
  }
}


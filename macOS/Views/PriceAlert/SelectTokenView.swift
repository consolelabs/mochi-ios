//
//  SelectTokenView.swift
//  Mochi Wallet (macOS)
//
//  Created by Oliver Le on 14/12/2022.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct SelectTokenView: View {
  @Environment(\.presentationMode) var presentationMode
  
  @ObservedObject var vm: WatchlistViewModel
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
    
  @State var shouldDismiss: Bool = false
  @State var isEditting: Bool = false
  @State var showShadow: Bool = true
  @State var showName: Bool = true
  let timer = Timer.publish(every: 15, tolerance: 1, on: .main, in: .common).autoconnect()

  
  var watchlistRows: some View {
    ForEach(vm.data, id: \.id) { item in
      NavigationLink(destination: NewPriceAlertView(
        vm: SetPriceAlertViewModel(alertService: PriceAlertServiceImpl(),
                                   tokenId: item.id, tokenName: item.name,
                                   tokenSymbol: item.symbol,
                                   price: item.currentPriceValue),
      shouldDismiss: $shouldDismiss)
      ) {
        HStack {
          HStack {
            WebImage(url: URL(string: item.image))
              .resizable()
              .scaledToFit()
              .clipShape(RoundedRectangle(cornerRadius: 4))
              .frame(width: 18, height: 18)
            
            VStack(alignment: .leading) {
              Text(item.symbol)
                .lineLimit(1)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.title)
              
              if showName {
                Text(item.name)
                  .lineLimit(1)
                  .font(.system(size: 12, weight: .medium, design: .rounded))
                  .foregroundColor(.subtitle)
              }
            }
          }
          
          Spacer()
          
          // Sparkline
          if !item.sparklineIn7d.price.isEmpty {
            SparklineView(prices: item.sparklineIn7d.price, color: item.priceChangePercentage7dColor)
              .shadow(color: item.priceChangePercentage7dColor.opacity(0.5), radius: showShadow ? 2 : 0, y: showShadow ? 2 : 0)
              .frame(width: 80)
          } else {
            Color.clear
              .frame(width: 80)
          }
          
          
          VStack(alignment: .trailing) {
            Text(item.currentPrice)
              .font(.system(size: 14, weight: .bold, design: .rounded))
              .foregroundColor(.title)
            
            Text(item.priceChangePercentage7dInCurrency)
              .font(.system(size: 12, weight: .semibold, design: .rounded))
              .foregroundColor(item.priceChangePercentage7dColor)
          }
          .frame(maxWidth: 100, alignment: .trailing)
        }
        .frame(maxHeight: 50)
      }
    }
    .onDelete { indexSet in
      vm.remove(at: indexSet)
    }
  }
  
  var searchCoinsRows: some View {
    ForEach(vm.searchCoins, id: \.presentedId) { item in
      // TODO: Update search row item then show set price alert
      NavigationLink(destination: Text("Set price")) {
        VStack(alignment: .leading) {
          Text(item.symbol.uppercased())
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.title)
          
          Text(item.name)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.subtitle)
        }
        .padding(.vertical, 4)
      }
    }
  }
  
  var body: some View {
    NavigationView {
      List {
        if (vm.isSearching) {
          searchCoinsRows
        } else {
          watchlistRows
        }
      }
      .onChange(of: shouldDismiss, perform: { shouldDismiss in
        if shouldDismiss {
          presentationMode.wrappedValue.dismiss()
        }
      })
      // TODO: Enable when update search row item
//      .searchable(text: $vm.searchTerm)
      .autocorrectionDisabled()
      .listStyle(PlainListStyle())
      .navigationTitle("Select token")
    }
    .overlay {
      if vm.isLoading {
        ActivityIndicator()
          .frame(width: 40, height: 40)
          .foregroundColor(.appPrimary)
      }
    }
    .onChange(of: discordId) { newValue in
      Task {
        await vm.fetchWatchlist()
      }
    }
    .onReceive(timer) { time in
      Task {
        await vm.fetchWatchlist(shouldShowLoading: false)
      }
    }
  }
}

struct SelectToken_Previews: PreviewProvider {
  static var previews: some View {
    WatchlistView(vm: WatchlistViewModel(defiService: DefiServiceMock()))
  }
}


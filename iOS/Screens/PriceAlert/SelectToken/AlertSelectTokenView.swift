//
//  AlertSelectTokenView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 05/04/2023.
//

import SwiftUI

struct AlertSelectTokenView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var vm = EditWatchlistViewModel(defiService: DefiServiceImpl())
  var didAddNewAlert: (Bool) -> Void = { _ in }

  var body: some View {
    NavigationView {
      ZStack {
        Theme.gray
          .ignoresSafeArea()
        ScrollView {
          if vm.isSearching {
            rows(data: vm.searchCoins)
          } else {
            rows(data: vm.data)
          }
        }
      }
      .searchable(text: $vm.searchTerm, prompt: Text("Search token to select"))
      .autocorrectionDisabled()
      .textInputAutocapitalization(.never)
      .listStyle(PlainListStyle())
      .navigationTitle("Select Token")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Select Token")
            .foregroundColor(Theme.text1)
            .font(.inter(size: 16, weight: .bold))
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: { dismiss() }) {
            Text("Cancel")
              .foregroundColor(Theme.text1)
              .font(.inter(size: 16, weight: .medium))
          }
        }
      }
    }
  }
  
  private func rows(data: [EditWatchlistItem]) -> some View {
    VStack(spacing: 8) {
      ForEach(data) { item in
        NavigationLink {
          NewPriceAlertView(
            data: TokenPriceHeaderData(
              id: item.id,
              tokenPair: TokenPair(left: item.symbol.uppercased(), right: "USDT"),
              pricingData: TokenPairPricingData(
                name: "\(item.symbol)/USDT",
                currentValue: item.currentPrice.toPriceFormat() ?? "0",
                currentUsdValue: item.currentPrice.toPriceFormat(withoutSymbol: false),
                h24PriceChangePercentage: nil,
                is24hPriceUp: nil
              )
            )
          ) { isSuccess in
            if isSuccess {
              didAddNewAlert(true)
              dismiss()
            }
          }
        } label: {
          itemRowView(item: item)
        }
      }
    }
    .padding(.horizontal)
  }
  
  private func itemRowView(item: EditWatchlistItem) -> some View {
    HStack {
      HStack(spacing: 8) {
        AsyncImage(url: URL(string: item.logo)) { phase in
          switch phase {
          case let .success(image):
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 20, height: 20)
              .frame(width: 24, height: 24)
              .clipShape(Circle())
          case .empty, .failure:
            Circle()
              .foregroundColor(Theme.gray)
              .frame(width: 20, height: 20)
              .frame(width: 24, height: 24)
          @unknown default:
            EmptyView()
          }
        }
        Text(item.symbol.uppercased())
          .foregroundColor(Theme.text1)
          .font(.inter(size: 15, weight: .bold))
      }
      .frame(width: 90, alignment: .leading)
      HStack(spacing: 6) {
        (
          Text("$")
            .foregroundColor(Theme.text4)
          +
          Text(item.currentPrice.toPriceFormat() ?? "NA")
            .foregroundColor(Theme.text1)
        )
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .font(.interSemiBold(size: 15))
        
        HStack(spacing: 0) {
          if item.priceChangePercentage7d >= 0 {
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
          Text(String(format: "%.2f", item.priceChangePercentage7d)+"%")
            .font(.interSemiBold(size: 11))
            .foregroundColor(
              item.priceChangePercentage7d > 0
              ? Color(red: 0.13, green: 0.75, blue: 0.58)
              : Color(red: 0.99, green: 0.37, blue: 0.35)
            )
        }
      }
      Spacer()
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12, style: .circular)
        .foregroundColor(.white)
    )
  }
}

struct AlertSelectTokenView_Previews: PreviewProvider {
  static var previews: some View {
    AlertSelectTokenView()
  }
}

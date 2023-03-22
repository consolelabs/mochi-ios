//
//  EditWatchlistView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 21/03/2023.
//

import SwiftUI

struct EditWatchlistView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var vm = EditWatchlistViewModel(defiService: DefiServiceImpl())

  var body: some View {
    NavigationView {
      ZStack {
        Theme.gray
          .ignoresSafeArea()
        ScrollView {
          if vm.isSearching {
            searchRows
          } else {
            watchlistRows
          }
        }
      }
      .searchable(text: $vm.searchTerm, prompt: Text("Search token to add"))
      .autocorrectionDisabled()
      .textInputAutocapitalization(.never)
      .listStyle(PlainListStyle())
      .navigationTitle("Edit Watchlist")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Edit Watchlist")
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
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { dismiss() }) {
            Text("Save")
              .foregroundColor(Theme.text1)
              .font(.inter(size: 16, weight: .semibold))
          }
        }
      }
    }
  }
  
  private var watchlistRows: some View {
    VStack(spacing: 8) {
      ForEach(vm.data) { item in
        HStack(spacing: 12) {
          Button(action: {
            vm.remove(symbol: item.symbol)
          }) {
            Asset.remove
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 20, height: 20)
              .frame(width: 24, height: 24)
          }
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
          Button(action: {}) {
            Asset.move
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 20, height: 20)
          }
        }
        .padding(16)
        .background(
          RoundedRectangle(cornerRadius: 12, style: .circular)
            .foregroundColor(.white)
        )
      }
    }
    .padding(.horizontal)
  }
  
  private var searchRows: some View {
    VStack(spacing: 8) {
      ForEach(vm.searchCoins) { item in
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
          Button(action: {
            if item.isSelected {
              vm.remove(symbol: item.symbol)
            } else {
              vm.add(coinId: item.id)
            }
          }) {
            if item.isSelected {
              Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundColor(Theme.green2)
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
            } else {
              Asset.add
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
            }
          }
        }
        .padding(16)
        .background(
          RoundedRectangle(cornerRadius: 12, style: .circular)
            .foregroundColor(.white)
        )
      }
    }
    .padding(.horizontal)
  }
}

struct EditWatchlistView_Previews: PreviewProvider {
  static var previews: some View {
    EditWatchlistView()
  }
}

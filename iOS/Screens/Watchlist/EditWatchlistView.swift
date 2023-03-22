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
      .navigationTitle(
        Text("Edit Watchlist")
          .foregroundColor(Theme.text1)
          .font(.inter(size: 16, weight: .bold))
      )
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
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
            vm.remove(symbol: item.name)
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
            Text(item.name.uppercased())
              .foregroundColor(Theme.text1)
              .font(.inter(size: 15, weight: .bold))
          }
          Spacer()
          HStack(spacing: 6) {
            Text("$0.00")
              .foregroundColor(Theme.text3)
              .font(.interSemiBold(size: 15))
            Text("0.00%")
              .foregroundColor(Theme.text3)
              .font(.interSemiBold(size: 11))
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
            Text(item.name.uppercased())
              .foregroundColor(Theme.text1)
              .font(.inter(size: 15, weight: .bold))
          }
          Spacer()
          HStack(spacing: 6) {
            Text("$0.00")
              .foregroundColor(Theme.text3)
              .font(.interSemiBold(size: 15))
            Text("0.00%")
              .foregroundColor(Theme.text3)
              .font(.interSemiBold(size: 11))
          }
          Spacer()
          Button(action: {
            if item.isSelected {
              vm.remove(symbol: item.name)
            } else {
              vm.add(coinId: item.id)
            }
          }) {
            if item.isSelected {
              Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundColor(.green)
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

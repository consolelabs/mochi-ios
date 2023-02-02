//
//  WatchlistView.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import Introspect

struct WatchlistView: View {
  @ObservedObject var vm: WatchlistViewModel
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
    
  @State var isEditting: Bool = false
  @State var showShadow: Bool = true
  @State var showName: Bool = true
  @State private var searchBar: UISearchBar?
  let timer = Timer.publish(every: 15, tolerance: 1, on: .main, in: .common).autoconnect()

  
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
              
              if showName {
                Text(item.name)
                  .font(.system(size: 12, weight: .medium, design: .rounded))
                  .foregroundColor(.subtitle)
              }
            }
          }
          .frame(width: reader.size.width / 3, alignment: .leading)
            
            Spacer()
          // Sparkline
          if !item.sparklineIn7d.price.isEmpty {
            SparklineView(prices: item.sparklineIn7d.price, color: item.priceChangePercentage7dColor)
              .shadow(color: item.priceChangePercentage7dColor.opacity(0.5), radius: showShadow ? 4 : 0, y: showShadow ? 4 : 0)

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
          if item.isSelected {
            vm.remove(symbol: item.symbol)
          } else {
            vm.add(coinId: item.id)
          }
        } label: {
          Image(systemName: item.isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
            .foregroundColor(item.isSelected ? .green : .appPrimary)
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
  
  var editButton: some View {
    Button {
      withAnimation {
        isEditting = true
      }
    } label: {
      Label("Edit watchlist", systemImage: "pencil")
    }
  }
   
  var showNameButton: some View {
    Button {
      withAnimation {
        showName.toggle()
      }
    } label: {
      Label("\(showName ? "✓" : "") Show name", systemImage: "text.magnifyingglass")
    }
  }
  
  var showShadowButton: some View {
    Button {
      withAnimation {
        showShadow.toggle()
      }
    } label: {
      Label("\(showShadow ? "✓" : "") Show shadow", systemImage: "sparkles.square.fill.on.square")
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
      .environment(\.editMode, .constant(isEditting ? .active : .inactive))
      .searchable(text: $vm.searchTerm)
      .autocorrectionDisabled()
      .textInputAutocapitalization(.never)
      .listStyle(PlainListStyle())
      .navigationBarTitleDisplayMode(.inline)
      .alert("Error", isPresented: $vm.showError, actions: {
        Button(action: {}) {
          Text("OK")
        }
      }, message: {
        Text(vm.errorMessage)
      })
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          VStack(alignment: .leading) {
            Text("Watchlist")
              .font(.system(.title3, design: .rounded))
              .fontWeight(.bold)
            
            Group {
              Text(Date().advanced(by: -(7 * 24 * 3600)).formatted(
                .dateTime
                  .day().month()
              ))
              .fontWeight(.semibold)
              +
              Text(" - ")
                .fontWeight(.semibold)
              +
              Text(Date().formatted(
                .dateTime
                  .day().month()
              ))
              .fontWeight(.semibold)
            }
            .font(.system(.caption, design: .rounded))
            .foregroundColor(.subtitle)
            
            Spacer()
          }
        }
        ToolbarItem {
          if (isEditting) {
            Button {
              withAnimation {
                isEditting = false
              }
            } label: {
              Text("Done")
                .fontWeight(.semibold)
            }
          } else {
            Menu {
              editButton
              showNameButton
              showShadowButton
            } label: {
              Image(systemName: "ellipsis.circle.fill")
            }
          }
        }
      }
    }
    .navigationViewStyle(.stack)
    .introspectNavigationController { nav in
      searchBar = nav.navigationBar.subviews.first { view in
        view is UISearchBar
      } as? UISearchBar
    }
      // MARK: - Bottom bar
    .overlay(alignment: .bottom) {
      if isEditting {
        HStack {
          Link(destination: URL(string: "https://getmochi.co/")!) {
            Text("Get")
              .font(.system(size: 14, weight: .semibold, design: .rounded))
              .foregroundColor(Color.white)
            +
            Text(" Mochi")
              .font(.system(size: 14, weight: .bold, design: .rounded))
              .foregroundColor(Color.accentColor)
          }
          Spacer()
          Button(action: { searchBar?.becomeFirstResponder() }) {
            Text("+Add")
              .font(.system(size: 14, weight: .bold, design: .rounded))
              .foregroundColor(Color.white)
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
              .background(Color.accentColor)
              .clipShape(Capsule())
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 11)
        .background(Color.gray)
      }
    }
      // MARK: - Loader
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

struct Watchlist_Previews: PreviewProvider {
  static var previews: some View {
    WatchlistView(vm: WatchlistViewModel(defiService: DefiServiceMock()))
  }
}


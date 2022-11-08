//
//  WatchlistView.swift
//  Mochi Wallet (macOS)
//
//  Created by Oliver Le on 02/11/2022.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct WatchlistView: View {

  @ObservedObject var vm: WatchlistViewModel
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
  
 
  @State private var isEditting: Bool = false
  @State private var showShadow: Bool = true
  @State private var showName: Bool = true
  @State private var isPinned: Bool = false
  
  private let timer = Timer.publish(every: 15, tolerance: 1, on: .main, in: .common).autoconnect()

  var watchlistRows: some View {
    ForEach(vm.data, id: \.id) { item in
      HStack {
        if isEditting {
          Button(action: {
            vm.remove(symbol: item.symbol)
          }) {
            Image(systemName: "minus.circle.fill")
              .foregroundColor(.red)
          }
          .buttonStyle(.borderless)
        }
        HStack {
          WebImage(url: URL(string: item.image))
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .frame(width: 18, height: 18)
          
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
      .contextMenu {
        Button {
          vm.remove(symbol: item.symbol)
        } label: {
          Label("Remove from watchlist", systemImage: "trash")
        }
      }
    }
    .onDelete { indexSet in
      
    }
    .onMove { indexSet, index in
    }
  }
  
  var searchCoinsRows: some View {
    ForEach(vm.searchCoins, id: \.presentedId) { item in
      HStack {
        Button {
          if item.isSelected {
            vm.remove(symbol: item.id)
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
      Label("\(showName ? "✓ " : "")Show name", systemImage: "text.magnifyingglass")
    }
  }
  
  var showShadowButton: some View {
    Button {
      withAnimation {
        showShadow.toggle()
      }
    } label: {
      Label("\(showShadow ? "✓ " : "")Show shadow", systemImage: "sparkles.square.fill.on.square")
    }
  }
  
  var body: some View {
    ZStack(alignment: .topLeading) {
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
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(VisualEffectView())
      
      List {
        if (vm.isSearching) {
          searchCoinsRows
        } else {
          watchlistRows
        }
      }
      .offset(y: vm.isSearching ? 0 : 50)
      .listStyle(SidebarListStyle())
    }
    .overlay {
      if vm.isLoading {
        ActivityIndicator()
          .frame(width: 40, height: 40)
          .foregroundColor(.appPrimary)
      }
    }
    .searchable(text: $vm.searchTerm)
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Button(action: { isPinned.toggle() }) {
          Label("Pinned", systemImage: isPinned ? "pin.circle.fill" : "pin.circle")
            .foregroundColor(isPinned ? Color.accentColor : nil)
        }
        
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
          HStack {
            Spacer()
            Menu {
              editButton
              showNameButton
              showShadowButton
              Divider()
              Button(action: {
                if #available(macOS 13.0, *) {
                  NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } else {
                  NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
              }) {
                Text("Settings...")
              }
            } label: {
              Label("More", systemImage: "ellipsis.circle.fill")
            }
          }
        }
      }
    }
    .onChange(of: isPinned) { isPinned in
      for window in NSApplication.shared.windows {
        window.level = isPinned ? .floating : .normal
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

struct SearchField : NSViewRepresentable {
  @Binding
  var text: String
  
  func makeNSView(context: Context) -> NSSearchField {
    let view = NSSearchField()
    
    return view
  }
  
  func updateNSView(_ view: NSSearchField, context: Context) {
    view.stringValue = text
  }
}

struct VisualEffectView: NSViewRepresentable {
  func makeNSView(context: Context) -> NSVisualEffectView {
    let view = NSVisualEffectView()
    
    view.blendingMode = .behindWindow
    view.isEmphasized = true
    view.material = .sidebar
    return view
  }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}

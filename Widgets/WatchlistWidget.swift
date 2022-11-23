//
//  Widgets.swift
//  Widgets
//
//  Created by Oliver Le on 18/10/2022.
//

import WidgetKit
import SwiftUI
import Intents
import Combine
import SDWebImageSwiftUI

// MARK: - Widget View Model
struct WidgetVM {
  let index: Int
  let id: String
  let name: String
  let symbol: String
  let currentPrice: String
  let priceChangePercentage24h: String
  let priceChangePercentage24hColor: Color
  let priceChangePercentage7dInCurrency: String
  let priceChangePercentage7dColor: Color
  var logoImage: Image?
  var sparklineIn7d: SparklineData
  
  init(index: Int, watchlist: DefiWatchList) {
    self.index = index
    self.id = watchlist.id
    self.name = watchlist.name
    self.symbol = watchlist.symbol.uppercased()
    self.sparklineIn7d = watchlist.sparklineIn7d
    
    let moneyFormatter = NumberFormatter()
    moneyFormatter.locale = Locale(identifier: "en_US")
    moneyFormatter.numberStyle = .currency
    self.currentPrice = moneyFormatter.string(from: NSNumber(value: watchlist.currentPrice)) ?? "NA"
    
    let percentFormatter = NumberFormatter()
    percentFormatter.locale = Locale(identifier: "en_US")
    percentFormatter.numberStyle = .percent
    percentFormatter.maximumFractionDigits = 2
    self.priceChangePercentage24h = "\(watchlist.priceChangePercentage24h > 0 ? "+" : "")\(percentFormatter.string(from: NSNumber(value: watchlist.priceChangePercentage24h / 100)) ?? "NA")"
    self.priceChangePercentage24hColor = watchlist.priceChangePercentage24h > 0 ? .green : .red
    self.priceChangePercentage7dInCurrency = "\(watchlist.priceChangePercentage7dInCurrency > 0 ? "+" : "")\(percentFormatter.string(from: NSNumber(value: watchlist.priceChangePercentage7dInCurrency / 100)) ?? "NA")"
    self.priceChangePercentage7dColor = watchlist.priceChangePercentage7dInCurrency > 0 ? .green : .red
  }
}

fileprivate extension DefiWatchList {
  static func placeholder() -> Self {
    return DefiWatchList(id: UUID().uuidString, name: "Bitcoin", symbol: "BTC", image: "", isPair: false, currentPrice: 23000, priceChangePercentage24h: 5, priceChangePercentage7dInCurrency: 3, sparklineIn7d: SparklineData(price: []))
  }
}

// MARK: - Widget Provider
class Provider: IntentTimelineProvider {
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
  
  private let defiService: DefiService
  private let defaultDiscordId = "963123183131709480"
  private var subscriptions = Set<AnyCancellable>()
  
  init(defiService: DefiService) {
    self.defiService = defiService
  }
  
  func placeholder(in context: Context) -> WatchlistEntry {
    let data = (0..<8).map { WidgetVM(index: $0, watchlist: DefiWatchList.placeholder())}
    return WatchlistEntry(date: Date(), configuration: ConfigurationIntent(), data: data, isPlaceHolder: true)
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WatchlistEntry) -> ()) {
    Task {
      let widgetVMs = await getWidgetVMs()
      let entry = WatchlistEntry(date: Date(), configuration: configuration, data: widgetVMs, isPlaceHolder: false)
      completion(entry)
    }
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    Task {
      let widgetVMs = await getWidgetVMs()
      let currentDate = Date()
      let entry = WatchlistEntry(date: currentDate, configuration: configuration, data: widgetVMs, isPlaceHolder: false)
      let reloadDate = Calendar.current.date(byAdding: .minute,
                                             value: 15,
                                             to: currentDate)!
      let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
      completion(timeline)
    }
  }
  
  private func getWidgetVMs() async -> [WidgetVM] {
    let widgetDiscordId = !discordId.isEmpty ? discordId : defaultDiscordId
    let result = await defiService.getWatchlist(pageSize: 20, userId: widgetDiscordId)
    guard case let .success(resp) = result else {
      return []
    }
    let widgetVMs = try? await withThrowingTaskGroup(of: WidgetVM.self) { group -> [WidgetVM]  in
      for (index, item) in resp.data.enumerated() {
        group.addTask {
          var widgetVM = WidgetVM(index: index, watchlist: item)
          let sysImage = try await withCheckedThrowingContinuation { continuation in
            SDWebImageDownloader.shared.downloadImage(with: URL(string: item.image)) { logoImage, data, error, success in
              if let logoImage = logoImage {
                continuation.resume(with: .success(logoImage))
              }
              if let error = error {
                continuation.resume(with: .failure(error))
              }
            }
          }
          #if os(iOS)
          widgetVM.logoImage = Image(uiImage: sysImage)
          #elseif os(macOS)
          widgetVM.logoImage = Image(nsImage: sysImage)
          #endif
          return widgetVM
        }
      }
      return try await group.reduce([], { result, item in
        return result + [item]
      })
    }
    return widgetVMs ?? []
  }
}

// MARK: - Widget Entry
struct WatchlistEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  let data: [WidgetVM]
  let isPlaceHolder: Bool
  
  func firstCol(row: Int) -> [WidgetVM] {
    return Array(data.sorted(by: { $0.index < $1.index }).prefix(row))
  }
  
  func secondCol(row: Int) -> [WidgetVM] {
    return Array(data.sorted(by: { $0.index < $1.index }).dropFirst(row).prefix(row))
  }
}

// MARK: - Widget View
struct WidgetsEntryView : View {
  @Environment(\.widgetFamily) var family

  var entry: Provider.Entry

  func nameView(name: String, symbol: String, logoImage: Image?) -> some View {
    HStack {
      if let image = logoImage {
        image
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 4))
          .frame(width: 20, height: 20)
          .redacted(reason: entry.isPlaceHolder ? .placeholder : [])
      } else {
        RoundedRectangle(cornerRadius: 4)
          .fill(Color.gray)
          .frame(width: 20, height: 20)
          .redacted(reason: entry.isPlaceHolder ? .placeholder : [])
      }
      
      VStack(alignment: .leading) {
        Text(symbol)
          .font(.system(size: 11))
          .bold()
          .lineLimit(1)
        if entry.configuration.showFullName?.boolValue ?? false {
          Text(name)
            .font(.system(size: 10))
            .lineLimit(1)
        }
      }
      .redacted(reason: entry.isPlaceHolder ? .placeholder : [])
    }
  }
  
  func sparkLine(prices: [Double], color: Color) -> some View {
    let showShadow = entry.configuration.showShadow?.boolValue ?? false
    return SparklineView(prices: prices, color: color)
      .shadow(color: color.opacity(0.5), radius: showShadow ? 4 : 0, y: showShadow ? 4 : 0)
      .frame(width: 80)
      .redacted(reason: entry.isPlaceHolder ? .placeholder : [])
  }
  
  func priceView(currentPrice: String, priceChangePercentage: String, color: Color) -> some View {
    VStack(alignment: .trailing) {
      Text(currentPrice)
        .bold()
        .font(.system(size: 12))
      
      Text(priceChangePercentage)
        .bold()
        .font(.system(size: 11))
        .foregroundColor(color)
    }
    .redacted(reason: entry.isPlaceHolder ? .placeholder : [])
    .frame(maxWidth: 100, alignment: .trailing)
  }
  
  func singleColLayoutView() -> some View {
    GeometryReader { reader in
      VStack {
        ForEach(entry.data.sorted(by: { $0.index < $1.index }).prefix(Int(reader.size.height) / 35), id: \.id) { item in
          HStack {
            nameView(name: item.name, symbol: item.symbol, logoImage: item.logoImage)
              .frame(width: reader.size.width / 3, alignment: .leading)

            
            // Sparkline
            if !item.sparklineIn7d.price.isEmpty {
              sparkLine(prices: item.sparklineIn7d.price, color: item.priceChangePercentage7dColor)
            } else {
              Color.clear
                .frame(width: 80)
                .redacted(reason: entry.isPlaceHolder ? .placeholder : [])
            }
            
            VStack(alignment: .trailing) {
              Text(item.currentPrice)
                .bold()
                .font(.system(size: 14))
              
              Text(item.priceChangePercentage7dInCurrency)
                .bold()
                .font(.system(size: 12))
                .foregroundColor(item.priceChangePercentage7dColor)
            }
            .redacted(reason: entry.isPlaceHolder ? .placeholder : [])
            .frame(width: reader.size.width / 3, alignment: .trailing)
          }
          .frame(height: 30)
        }
      }
    }
    .padding()
  }
  
  func twoColLayoutView(row: Int) -> some View {
    return HStack(spacing: 8) {
      VStack {
        ForEach(entry.firstCol(row: row), id: \.id) { item in
          HStack {
            nameView(name: item.name, symbol: item.symbol, logoImage: item.logoImage)

            Spacer()

            priceView(currentPrice: item.currentPrice,
                      priceChangePercentage: item.priceChangePercentage7dInCurrency,
                      color: item.priceChangePercentage7dColor)
          }
          .frame(height: 30)
        }

        Spacer()
      }
      
      VStack {
        ForEach(entry.secondCol(row: row), id: \.id) { item in
          HStack {
            nameView(name: item.name, symbol: item.symbol, logoImage: item.logoImage)
            
            Spacer()
            
            priceView(currentPrice: item.currentPrice,
                      priceChangePercentage: item.priceChangePercentage7dInCurrency,
                      color: item.priceChangePercentage7dColor)
          }
          .frame(height: 30)
        }
        
        Spacer()
      }
    }
    .padding(.vertical, 8)
    .padding(.horizontal)
  }
  
  var body: some View {
    if entry.configuration.showMore?.boolValue == true {
      switch family {
      case .systemMedium:
        twoColLayoutView(row: 4)
      case .systemLarge:
        twoColLayoutView(row: 8)
      default:
        Text("No support this size")
      }
    } else {
      singleColLayoutView()
    }
  }
}

// MARK: - Widget Main
@main
struct WatchlistWidget: Widget {
  let kind: String = "Watchlist"
  
  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider(defiService: DefiServiceImpl())) { entry in
      WidgetsEntryView(entry: entry)
    }
    .configurationDisplayName("Mochi Wallet")
    .description("Track Your Defi Watchlist")
    .supportedFamilies([.systemMedium, .systemLarge])
  }
}

struct Widgets_Previews: PreviewProvider {
  static var previews: some View {
    WidgetsEntryView(entry: WatchlistEntry(date: Date(), configuration: ConfigurationIntent(), data: [], isPlaceHolder: false))
      .previewContext(WidgetPreviewContext(family: .systemLarge))
  }
}


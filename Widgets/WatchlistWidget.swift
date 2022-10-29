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
    self.priceChangePercentage24h = "\(watchlist.priceChangePercentage24h > 0 ? "+" : "")\(percentFormatter.string(from: NSNumber(value: watchlist.priceChangePercentage24h / 1000)) ?? "NA")"
    self.priceChangePercentage24hColor = watchlist.priceChangePercentage24h > 0 ? .green : .red
    self.priceChangePercentage7dInCurrency = "\(watchlist.priceChangePercentage7dInCurrency > 0 ? "+" : "-")\(percentFormatter.string(from: NSNumber(value: watchlist.priceChangePercentage7dInCurrency / 1000)) ?? "NA")"
    self.priceChangePercentage7dColor = watchlist.priceChangePercentage7dInCurrency > 0 ? .green : .red
  }
}

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
    WatchlistEntry(date: Date(), configuration: ConfigurationIntent(), data: [])
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WatchlistEntry) -> ()) {
    Task {
      let widgetDiscordId = !discordId.isEmpty ? discordId : defaultDiscordId
      let result = await defiService.getWatchlist(userId: widgetDiscordId)
      guard case let .success(resp) = result else {
        return
      }
      let widgetVMs = try await withThrowingTaskGroup(of: WidgetVM.self) { group -> [WidgetVM]  in
        for (index, item) in resp.data.enumerated() {
          group.addTask {
            var widgetVM = WidgetVM(index: index, watchlist: item)
            let uiImage = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage, Error>) in
              SDWebImageDownloader.shared.downloadImage(with: URL(string: item.image)) { logoImage, data, error, success in
                if let logoImage = logoImage {
                  continuation.resume(with: .success(logoImage))
                }
                if let error = error {
                  continuation.resume(with: .failure(error))
                }
              }
            }
            widgetVM.logoImage = Image(uiImage: uiImage)
            return widgetVM
          }
        }
        return try await group.reduce([], { result, item in
          return result + [item]
        })
      }
      let entry = WatchlistEntry(date: Date(), configuration: configuration, data: widgetVMs)
      completion(entry)
    }
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    Task {
      let widgetDiscordId = !discordId.isEmpty ? discordId : defaultDiscordId
      let result = await defiService.getWatchlist(userId: widgetDiscordId)
      guard case let .success(resp) = result else {
        return
      }
      let widgetVMs = try await withThrowingTaskGroup(of: WidgetVM.self) { group -> [WidgetVM]  in
        for (index, item) in resp.data.enumerated() {
          group.addTask {
            var widgetVM = WidgetVM(index: index, watchlist: item)
            let uiImage = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage, Error>) in
              SDWebImageDownloader.shared.downloadImage(with: URL(string: item.image)) { logoImage, data, error, success in
                if let logoImage = logoImage {
                  continuation.resume(with: .success(logoImage))
                }
                if let error = error {
                  continuation.resume(with: .failure(error))
                }
              }
            }
            widgetVM.logoImage = Image(uiImage: uiImage)
            return widgetVM
          }
        }
        return try await group.reduce([], { result, item in
          return result + [item]
        })
      }
      var entries: [WatchlistEntry] = []
      for hourOffset in 0..<1 {
        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
        let entry = WatchlistEntry(date: Date(), configuration: configuration, data: widgetVMs)
        entries.append(entry)
      }
      let timeline = Timeline(entries: entries, policy: .atEnd)
      completion(timeline)
    }
  }
}

struct WatchlistEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  let data: [WidgetVM]
}

struct WidgetsEntryView : View {
  var entry: Provider.Entry

  func nameView(name: String, symbol: String) -> some View {
    VStack(alignment: .leading) {
      Text(symbol)
        .font(.system(size: 14))
        .bold()
      if entry.configuration.showFullName?.boolValue ?? false {
        Text(name)
          .font(.system(size: 11))
      }
    }
  }
  
  var body: some View {
    GeometryReader { reader in
      VStack {
        ForEach(entry.data.sorted(by: { $0.index < $1.index }).prefix(Int(reader.size.height) / 35), id: \.id) { item in
          HStack {
            HStack {
              if let image = item.logoImage {
                image
                  .resizable()
                  .scaledToFit()
                  .clipShape(RoundedRectangle(cornerRadius: 4))
                  .frame(width: 20, height: 20)
              } else {
                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.gray)
                  .frame(width: 20, height: 20)
              }
              
              nameView(name: item.name, symbol: item.symbol)
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
          .frame(height: 30)
        }
      }
    }
    .padding()
  }
}

@main
struct WatchlistWidget: Widget {
  let kind: String = "Watchlist"
  
  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider(defiService: DefiServiceImpl())) { entry in
      WidgetsEntryView(entry: entry)
    }
    .configurationDisplayName("Mochi Wallet")
    .description("Track Your Defi Watchlist")
    .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
  }
}

struct Widgets_Previews: PreviewProvider {
  static var previews: some View {
    WidgetsEntryView(entry: WatchlistEntry(date: Date(), configuration: ConfigurationIntent(), data: []))
      .previewContext(WidgetPreviewContext(family: .systemLarge))
  }
}


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
  private let defiService: DefiService
  private var subscriptions = Set<AnyCancellable>()
  
  init(defiService: DefiService) {
    self.defiService = defiService
  }
  
  func placeholder(in context: Context) -> WatchlistEntry {
    WatchlistEntry(date: Date(), configuration: ConfigurationIntent(), data: [])
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WatchlistEntry) -> ()) {
    defiService.fetchWatchlist(userId: configuration.discordId ?? "")
      .sink { result in
        switch result {
        case .finished:
          break
        case .failure(let error):
          print(error)
          break
        }
      } receiveValue: { resp in
        var widgetVMs: [WidgetVM] = []
        let dispatchGroup = DispatchGroup()
        resp.data.enumerated().forEach { (index, item) in
          dispatchGroup.enter()
          var widgetVM = WidgetVM(index: index, watchlist: item)
          SDWebImageDownloader.shared.downloadImage(with: URL(string: item.image)) { logoImage, data, error, success in
            if let logoImage = logoImage {
              widgetVM.logoImage = Image(uiImage: logoImage)
            }
            widgetVMs.append(widgetVM)
            dispatchGroup.leave()
          }
        }
        dispatchGroup.wait()
        let entry = WatchlistEntry(date: Date(), configuration: configuration, data: widgetVMs)
        completion(entry)
      }
      .store(in: &subscriptions)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    defiService.fetchWatchlist(userId: configuration.discordId ?? "")
      .sink { result in
        switch result {
        case .finished:
          break
        case .failure(let error):
          print(error)
          break
        }
      } receiveValue: { resp in
        var widgetVMs: [WidgetVM] = []
        let dispatchGroup = DispatchGroup()
        resp.data.enumerated().forEach { (index, item) in
          dispatchGroup.enter()
          var widgetVM = WidgetVM(index: index, watchlist: item)
          SDWebImageDownloader.shared.downloadImage(with: URL(string: item.image)) { logoImage, data, err, isSuccess in
            if let logoImage = logoImage {
              widgetVM.logoImage = Image(uiImage: logoImage)
            }
            widgetVMs.append(widgetVM)
            dispatchGroup.leave()
          }
        }
        dispatchGroup.wait()
        var entries: [WatchlistEntry] = []
        for hourOffset in 0..<1 {
          let currentDate = Date()
          let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
          let entry = WatchlistEntry(date: entryDate, configuration: configuration, data: widgetVMs)
          entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
      }
      .store(in: &subscriptions)
  }
}

struct WatchlistEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  let data: [WidgetVM]
}

struct WidgetsEntryView : View {
  var entry: Provider.Entry
  
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
              Line(data: item.sparklineIn7d.price,
                   color: item.priceChangePercentage24hColor,
                   frame: .constant(CGRect(x: 0, y: 0, width: 80, height: 270)))
                .frame(width: 80)
            } else {
              RoundedRectangle(cornerRadius: 4)
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
      .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}

struct Line: View {
  var data: [(Double)]
  var color: Color
  @Binding var frame: CGRect
  
  let padding:CGFloat = 30
  
  var stepWidth: CGFloat {
    if data.count < 2 {
      return 0
    }
    return frame.size.width / CGFloat(data.count-1)
  }
  var stepHeight: CGFloat {
    var min: Double?
    var max: Double?
    let points = self.data
    if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
      min = minPoint
      max = maxPoint
    }else {
      return 0
    }
    if let min = min, let max = max, min != max {
      if (min <= 0){
        return (frame.size.height-padding) / CGFloat(max - min)
      }else{
        return (frame.size.height-padding) / CGFloat(max + min)
      }
    }
    
    return 0
  }
  var path: Path {
    let points = self.data
    return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
  }
  
  public var body: some View {
    
    ZStack {
      
      self.path
        .stroke(color, style: StrokeStyle(lineWidth: 1, lineJoin: .bevel))
        .rotationEffect(.degrees(180), anchor: .center)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        .drawingGroup()
    }
  }
}

extension Path {
  
  static func lineChart(points:[Double], step:CGPoint) -> Path {
    var path = Path()
    if (points.count < 2){
      return path
    }
    guard let offset = points.min() else { return path }
    let p1 = CGPoint(x: 0, y: CGFloat(points[0]-offset)*step.y)
    path.move(to: p1)
    for pointIndex in 1..<points.count {
      let p2 = CGPoint(x: step.x * CGFloat(pointIndex), y: step.y*CGFloat(points[pointIndex]-offset))
      path.addLine(to: p2)
    }
    return path
  }
}

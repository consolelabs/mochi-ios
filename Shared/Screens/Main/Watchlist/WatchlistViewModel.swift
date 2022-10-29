//
//  WatchlistViewModel.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import SwiftUI
class WatchlistViewModel: ObservableObject {
  struct WatchlistPresenter {
    let id: String
    let name: String
    let symbol: String
    let image: String
    let currentPrice: String
    let priceChangePercentage24h: String
    let priceChangePercentage24hColor: Color
    let priceChangePercentage7dInCurrency: String
    let priceChangePercentage7dColor: Color
    var sparklineIn7d: SparklineData
    
    init(watchlist: DefiWatchList) {
      self.id = watchlist.id
      self.name = watchlist.name
      self.symbol = watchlist.symbol.uppercased()
      self.image = watchlist.image
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
  
  private let defiService: DefiService
  
  @Published var data: [WatchlistPresenter] = []
  
  init(defiService: DefiService) {
    self.defiService = defiService
  }
  
  
  func fetchWatchlist(with discordId: String = "") async {
    let defaultDiscordId = "963123183131709480"
    let userId = !discordId.isEmpty ? discordId : defaultDiscordId
    let result = await defiService.getWatchlist(userId: userId)
    switch result {
    case .success(let success):
      DispatchQueue.main.async {
        self.data = success.data.map(WatchlistPresenter.init)
      }
    case .failure(let failure):
      print(failure)
      print(failure.customMessage)
    }
  }
}


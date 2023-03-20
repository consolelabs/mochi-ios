//
//  WatchlistViewModel.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import SwiftUI
import Combine
import WidgetKit
import OSLog

class WatchlistViewModel: ObservableObject {
  // MARK: - Presenter
  struct WatchlistPresenter: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let image: String
    let currentPrice: String
    let currentPriceValue: Double
    let priceChangePercentage24h: String
    let priceChangePercentage24hColor: Color
    let priceChangePercentage7dInCurrency: String
    let priceChangePercentage7dColor: Color
    var sparklineIn7d: SparklineData
    let priceChangePercentage24hValue: Double
    let priceChangePercentage7dValue: Double

    init(watchlist: DefiWatchList) {
      self.id = watchlist.id
      self.name = watchlist.name
      self.symbol = watchlist.symbol.uppercased()
      self.image = watchlist.image
      self.currentPriceValue = watchlist.currentPrice
      self.sparklineIn7d = watchlist.sparklineIn7d
      self.priceChangePercentage24hValue = watchlist.priceChangePercentage24h
      self.priceChangePercentage7dValue = watchlist.priceChangePercentage7dInCurrency
      
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
  
  struct SearchCoinPresenter {
    let presentedId: String
    let id: String
    let name: String
    let symbol: String
    var isSelected: Bool
    
    init(data: SearchCoinsResponse.SearchCoinsData) {
      self.presentedId = UUID().uuidString
      self.id = data.id
      self.name = data.name
      self.symbol = data.symbol
      self.isSelected = false
    }
  }
 
  // MARK: - Properties
  private let defiService: DefiService
  private let defaultDiscordId = "963123183131709480"
  private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "mochi", category: "WatchlistViewModel")
  private var subscriptions = Set<AnyCancellable>()
 
  @Published var isLoading: Bool = false
  @Published var searchTerm: String = ""
  @Published var isSearching: Bool = false
  @Published var showError: Bool = false
  @Published var errorMessage: String = ""
  @Published var data: [WatchlistPresenter] = []
  @Published var searchCoins: [SearchCoinPresenter] = []
  @Published var selectedCoins = Set<String>()
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
  
  // MARK: - Init
  init(defiService: DefiService) {
    self.defiService = defiService
    observeSearching()
    Task(priority: .high) {
      await fetchWatchlist()
    }
  }
 
  func fetchWatchlist(shouldShowLoading: Bool = true) async {
    if shouldShowLoading {
      await MainActor.run {
        self.isLoading = true
      }
 
    }
    let userId = !discordId.isEmpty ? discordId : defaultDiscordId
    let result = await defiService.getWatchlist(pageSize: 100, userId: userId)
    await MainActor.run {
      self.isLoading = false
    }
    switch result {
    case .success(let success):
      await MainActor.run {
          self.data = success.data.data.map(WatchlistPresenter.init)
      }
      reloadWidgetDataIfNeeded()
    case .failure(let failure):
      logger.error("Fetch watchlist failed, error: \(failure.customMessage)")
    }
  }
  
  func observeSearching() {
    $searchTerm
      .dropFirst()
      .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
      .removeDuplicates()
      .handleEvents(receiveOutput: { output in
        self.isSearching = !output.isEmpty
      })
      .combineLatest($data)
      .flatMap { query, data in
        Future { promise in
          Task {
            guard !query.isEmpty else {
              promise(.success([]))
              return
            }
            let result = await self.defiService.queryCoins(query: query)
            switch result {
            case .success(let resp):
              promise(.success(resp.data.map { coin in
                let isSelected = data.contains(where: {$0.id == coin.id })
                var coinPresenter = SearchCoinPresenter(data: coin)
                coinPresenter.isSelected = isSelected
                return coinPresenter
              }))
            case .failure(let error):
              print(error.customMessage)
            }
          }
        }
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
      .assign(to: &$searchCoins)
  }
  
  func add(coinId: String) {
    guard !discordId.isEmpty else {
      self.errorMessage = "Unlock this feature by connect to Discord"
      self.showError = true
      return
    }
    Task(priority: .high) {
      await MainActor.run {
        self.isLoading = true
      }
      let result = await defiService.addWatchlist(coinId: coinId, userId: discordId)
      await MainActor.run {
        self.isLoading = false
      }
      switch result {
      case .success:
        await fetchWatchlist()
      case .failure(let error):
        print(error.customMessage)
      }
    }
  }
  
  func remove(at indexSet: IndexSet) {
    for index in indexSet {
      let item = data[index]
      remove(symbol: item.symbol)
    }
  }
  
  func remove(symbol: String) {
    guard !discordId.isEmpty else {
      self.errorMessage = "Unlock this feature by connect to Discord"
      self.showError = true
      return
    }
    self.isLoading = true
    Task(priority: .high) {
      let result = await defiService.removeWatchlist(symbol: symbol, userId: discordId)
      await MainActor.run {
        self.isLoading = false
      }
      switch result {
      case .success:
        await fetchWatchlist()
      case .failure(let error):
        print(error.customMessage)
      }
    }
  }
  
  func reloadWidgetDataIfNeeded() {
    WidgetCenter.shared.reloadAllTimelines()
  }
}


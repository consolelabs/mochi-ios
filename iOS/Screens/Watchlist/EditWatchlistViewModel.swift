//
//  EditWatchlistViewModel.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 22/03/2023.
//

import SwiftUI
import Combine
import WidgetKit
import OSLog

struct EditWatchlistItem: Identifiable {
  let id: String
  var logo: String
  var symbol: String
  var priceChangePercentage7d: Double
  var currentPrice: Double
  var isSelected: Bool = false
}

extension EditWatchlistItem {
  static let mock = Self(
    id: UUID().uuidString,
    logo: "https://assets.coingecko.com/coins/images/1/thumb/bitcoin.png",
    symbol: "btc",
    priceChangePercentage7d: 0,
    currentPrice: 0
  )
}

@MainActor
class EditWatchlistViewModel: ObservableObject {
  // MARK: - Properties
  private let defiService: DefiService
  private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "mochi", category: "EditWatchlistViewModel")
  private var subscriptions = Set<AnyCancellable>()
 
  @Published var isLoading: Bool = false
  @Published var searchTerm: String = ""
  @Published var isSearching: Bool = false
  @Published var showError: Bool = false
  @Published var errorMessage: String = ""
  @Published var data: [EditWatchlistItem] = []
  @Published var searchCoins: [EditWatchlistItem] = []
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
    guard !discordId.isEmpty else { return }
    
    if shouldShowLoading {
      self.isLoading = true
    }
    
    let result = await defiService.getWatchlist(pageSize: 100, userId: discordId)
    
    switch result {
    case .success(let success):
      self.data = success.data.data.map { item in
        EditWatchlistItem(
          id: item.id,
          logo: item.image,
          symbol: item.symbol,
          priceChangePercentage7d: item.priceChangePercentage7dInCurrency,
          currentPrice: item.currentPrice
        )
      }
    case .failure(let failure):
      logger.error("Fetch watchlist failed, error: \(failure.customMessage)")
    }
    
    self.isLoading = false
  }
  
  private func observeSearching() {
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
              let items = await withTaskGroup(of: EditWatchlistItem?.self) { group -> [EditWatchlistItem] in
                for item in resp.data {
                  let isSelected = self.data.contains(where: { $0.id == item.id })
                  group.addTask {
                    let result = await self.defiService.getCoin(id: item.id)
                    guard case let .success(resp) = result else { return nil }
                    let coin = resp.data
                    return EditWatchlistItem(
                      id: coin.id,
                      logo: coin.image.small,
                      symbol: coin.symbol,
                      priceChangePercentage7d: coin.marketData.priceChangePercentage7dInCurrency.usd,
                      currentPrice: coin.marketData.currentPrice.usd,
                      isSelected: isSelected
                    )
                  }
                }
                return await group.reduce([]) { result, item in
                  guard let item = item else { return result }
                  return result + [item]
                }
              }
              promise(.success(items))
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
}


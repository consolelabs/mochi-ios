//
//  PriceAlertListViewModel.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 03/04/2023.
//

import Combine
import SwiftUI
import OSLog

@MainActor
final class PriceAlertListViewModel: ObservableObject {
  @Published var sections: [PriceAlertSection] = []
  @Published var isLoading = false
  @Published var error: String = ""
  @Published var showNewAlert: Bool = false
 
  
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
  
  private let mochiService: MochiService
  private let logger = Logger(subsystem: "so.console.mochi", category: "PriceAlertListViewModel")
  
  init(mochiService: MochiService) {
    self.mochiService = mochiService
    Task(priority: .high) {
      await fetchList()
    }
  }
  
  func fetchList() async {
    self.isLoading = true
    let result = await mochiService.getPriceAlert(discordID: discordId)
    
    switch result {
    case let .failure(error):
      logger.error("mochiService.getPriceAlert failed, error: \(error)")
    case let .success(resp):
      let priceAlertRowGroup: [TokenPair: [PriceAlertRowItem]] = resp.data.reduce([:]) { groups, priceAlert in
        let item = PriceAlertRowItem(from: priceAlert)
        var newGroups = groups
        guard let items = groups[item.pair] else {
          newGroups[item.pair] = [item]
          return newGroups
        }
        newGroups[item.pair] = items + [item]
        return newGroups
      }
    
      var sections = priceAlertRowGroup.map { key, value in
        return PriceAlertSection(
          id: "\(key.left)/\(key.right)",
          tokenPair: key,
          pricingData: nil,
          rows: value
        )
      }.sorted(by: { $0.tokenPair.left < $1.tokenPair.left })
      
      // Fetch pricing data
      let pricingData = await withTaskGroup(of: (String, TokenPairPricingData?).self) { group -> [(String, TokenPairPricingData?)] in
       
        for section in sections {
          group.addTask {
            let result = await self.mochiService.getBinanceCoin(symbol: section.tokenPair.left)
            switch result {
            case let .failure(error):
              self.logger.error("fetch binance coin for \(section.tokenPair.left) failed, error: \(error)")
              return (section.id, nil)
            case let .success(resp):
              let coin = resp.data
              let priceValue = Double(coin.price)
              let price = TokenPairPricingData(
                name: coin.symbol,
                currentValue: priceValue?.toPriceFormat() ?? "0",
                currentUsdValue: priceValue?.toPriceFormat(withoutSymbol: false),
                h24PriceChangePercentage: nil,
                is24hPriceUp: nil
              )
              return (section.id, price)
            }
          }
        }
        return await group.reduce([]) { result, item in
          return result + [item]
        }
      }
      
      for (sectionId, data) in pricingData {
        if let data, let index = sections.firstIndex(where: { $0.id == sectionId }) {
          sections[index].pricingData = data
        }
      }
  
      self.isLoading = false
      self.sections = sections
   }
  }
  
  func deleteItem(sectionId: String, item: PriceAlertRowItem) {
    guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) else {
      return
    }
   
    var rows = sections[sectionIndex].rows
    guard let rowIndex = rows.firstIndex(where: { $0.id == item.id }) else {
      return
    }
    rows.remove(at: rowIndex)
    
    // remove hole section when all rows is removed
    if rows.isEmpty {
      sections.remove(at: sectionIndex)
    } else {
      self.sections[sectionIndex].rows = rows
    }
    
    Task {
      _ = await mochiService.deletePriceAlert(symbol: item.symbol, discordID: discordId)
    }
  }
}

struct TokenPair {
  let left: String
  let right: String
}

extension TokenPair: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(left)
    hasher.combine(right)
  }
}

struct TokenPairPricingData {
  let name: String
  let currentValue: String
  let currentUsdValue: String?
  let h24PriceChangePercentage: String?
  let is24hPriceUp: Bool?
  
  static func mock(with pair: TokenPair) -> Self {
    return TokenPairPricingData(
      name: "\(pair.left)/\(pair.right)",
      currentValue: "0.45",
      currentUsdValue: "$0.45",
      h24PriceChangePercentage: "2.66%",
      is24hPriceUp: true
    )
  }
}

struct PriceAlertSection: Identifiable {
  let id: String
  let tokenPair: TokenPair
  var pricingData: TokenPairPricingData?
  var rows: [PriceAlertRowItem]
}

extension PriceAlertSection {
  static var mock: Self {
    return PriceAlertSection(
      id: UUID().uuidString,
      tokenPair: TokenPair(left: "ETH", right: "USDT"),
      rows: .init(
        repeating: PriceAlertRowItem(
          id: 0,
          symbol: "ETH",
          currency: "USDT",
          pair: TokenPair(left: "ETH", right: "USDT"),
          type: .changeIsOver,
          frequency: .always,
          value: "1500",
          priceByPercent: 0
        ),
        count: 3)
    )
  }
}

struct PriceAlertRowItem: Identifiable {
  enum AlertType {
    case priceReaches
    case priceRisesAbove
    case priceDropsTo
    case changeIsOver
    case changeIsUnder
    case h24ChangeIsOver
    case h24ChangeIsDown
    
    var description: String {
      switch self {
      case .priceReaches:
        return "Price reaches"
      case .priceRisesAbove:
        return "Price rises above"
      case .priceDropsTo:
        return "Price drops to"
      case .changeIsOver:
        return "Change is over"
      case .changeIsUnder:
        return "Change is under"
      case .h24ChangeIsOver:
        return "24H change is over"
      case .h24ChangeIsDown:
        return "24H change is down"
      }
    }
    
    var icon: String {
      switch self {
      case .priceReaches:
        return "ico_dollar_square"
      case .priceRisesAbove:
        return "ico_arrow_up_square"
      case .priceDropsTo:
        return "ico_arrow_down_square"
      case .changeIsOver:
        return "ico_arrow_up_square"
      case .changeIsUnder:
        return "ico_arrow_down_square"
      case .h24ChangeIsOver:
        return "ico_arrow_up_square"
      case .h24ChangeIsDown:
        return "ico_arrow_down_square"
      }
    }
  }
  
  enum Frequency {
    case onlyOnce
    case onceADay
    case always
    
    var description: String {
      switch self {
      case .onlyOnce:
        return "Only once"
      case .onceADay:
        return "Once a day"
      case .always:
        return "Always"
      }
    }
  }
 

  
  let id: Int
  let symbol: String
  let currency: String
  let pair: TokenPair
  let type: AlertType
  let frequency: Frequency
  let value: String
  let priceByPercent: Double
  
  var icon: String {
    return type.icon
  }
  
  var title: String {
    let isPercentageType = [
      .changeIsOver,
      .changeIsUnder,
      .h24ChangeIsDown,
      .h24ChangeIsOver
    ].contains(self.type)
    let prefix =  isPercentageType ? "" : "$"
    let suffix = isPercentageType ? "%" : ""
    return "\(self.type.description) \(prefix)\(value)\(suffix)"
  }
    
  var description: String {
    return "\(self.frequency.description)"
  }
}

extension PriceAlertRowItem {
  init(from data: UserTokenPriceAlert) {
    self.id = data.id
    self.symbol = data.symbol
    self.currency = data.currency
    self.value = "\(data.value)"
    self.priceByPercent = data.priceByPercent
    self.pair = TokenPair(left: data.symbol, right: data.currency)
      
    switch data.alertType {
    case .priceReaches:
      self.type = .priceReaches
    case .priceRisesAbove:
      self.type = .priceRisesAbove
    case .priceDropsTo:
      self.type = .priceDropsTo
    case .changeIsOver:
      self.type = .changeIsOver
    case .changeIsUnder:
      self.type = .changeIsUnder
    }
    
    switch data.frequency {
    case .always:
      self.frequency = .always
    case .onceADay:
      self.frequency = .onceADay
    case .onlyOnce:
      self.frequency = .onlyOnce
    }
  }
}

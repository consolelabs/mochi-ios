//
//  AlertListViewModel.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 18/11/2022.
//

import SwiftUI
import OSLog
import UserNotifications

struct AlertPresenter: Identifiable {
  let id: String
  let tokenId: String
  let price: String
  let priceValue: Double
  let trend: String
  let trendValue: PriceTrend
  let trendSymbolName: String
  let trendColor: Color
  let isEnable: Bool
  var tokenName: String = ""
  var symbol: String = ""
  var image: String = ""
  
  init(alert: GetUserPriceAlertResponse.PriceAlert) {
    self.id = alert.id
    self.tokenId = alert.tokenId
    self.isEnable = alert.isEnable
    self.trendValue = alert.trend
    self.trend = alert.trend.rawValue
    self.trendSymbolName = alert.trend == .up ? "arrow.up.square.fill" : "arrow.down.square.fill"
    self.trendColor = alert.trend == .up ? .green : .red
    self.priceValue = alert.priceSet
    
    let moneyFormatter = NumberFormatter()
    moneyFormatter.locale = Locale(identifier: "en_US")
    moneyFormatter.numberStyle = .currency
    self.price = moneyFormatter.string(from: NSNumber(value: alert.priceSet)) ?? "NA"
  }
}

@MainActor
class AlertListViewModel: ObservableObject {
  private let logger = Logger(subsystem: "so.console.mochi", category: "AlertListViewModel")
  private let alertService: PriceAlertService
  
  @Published var isLoading: Bool = false
  @Published var data: [AlertPresenter] = []

  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
  
  init(alertService: PriceAlertService) {
    self.alertService = alertService
    fetchAlertList()
  }
  
  func requestNotificationAuth() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error {
        self.logger.error("Request notification auth error: \(error.localizedDescription)")
      }
      self.logger.debug("Request notification auth: \(granted ? "granted" : "deny")")
      if granted {
        DispatchQueue.main.async {
          #if os(iOS)
          UIApplication.shared.registerForRemoteNotifications()
          #elseif os(macOS)
          NSApplication.shared.registerForRemoteNotifications()
          #endif
        }
      }
    }
  }
  
  func fetchAlertList(shouldShowLoading: Bool = true) {
    guard !discordId.isEmpty else {
      return
    }
    
    Task(priority: .high) {
      if shouldShowLoading {
        self.isLoading = true
      }
      let result = await alertService.getUserPriceAlert(discordId: discordId)
      switch result {
      case .success(let success):
        let data = try? await withThrowingTaskGroup(of: AlertPresenter.self) { group -> [AlertPresenter] in
          for item in success.data {
            group.addTask {
              var alertPresenter = AlertPresenter(alert: item)
              let fetchCoinResult = await DefiServiceImpl().getCoin(id: item.tokenId)
              switch fetchCoinResult {
              case .success(let coin):
                alertPresenter.tokenName = coin.data.name
                alertPresenter.image = coin.data.image.small
                alertPresenter.symbol = coin.data.symbol
              case .failure(let failure):
                alertPresenter.tokenName = "NA"
                alertPresenter.symbol = "NA"
                self.logger.error("Fetch coin error: \(failure.customMessage)")
              }
              return alertPresenter
            }
          }
          return try await group.reduce([], { result, item in
            return result + [item]
          })
        }
        self.data = data?.sorted(by: { $0.tokenId < $1.tokenId }) ?? []
      case .failure(let failure):
        self.logger.error("Fetch alert list error: \(failure.customMessage)")
      }
      self.isLoading = false
    }
  }
  
  func toggleAlert(id: String) {
    guard let item = data.first(where: { $0.id == id }) else {
      return
    }
    var deviceId = ""
    #if os(iOS)
    deviceId = UIDevice().identifierForVendor?.uuidString ?? ""
    #elseif os(macOS)
    deviceId = Util.hardwareUUID() ?? ""
    #endif
    self.updatePriceAlert(id: item.id,
                          tokenId: item.tokenId,
                          symbol: item.symbol,
                          deviceId: deviceId,
                          discordId: discordId,
                          priceSet: item.priceValue,
                          trend: item.trendValue,
                          isEnable: !item.isEnable)

  }
    
  func deleteAlert(indexSet: IndexSet) {
    for index in indexSet {
      let item = data[index]
      deleteAlert(id: item.id)
    }
  }
  
  func deleteAlert(id: String) {
    Task(priority: .high) {
      self.isLoading = true
      let result = await alertService.deletePriceAlert(id: id)
      self.isLoading = false
      switch result {
      case .success:
        self.logger.info("Delete alert success")
        self.fetchAlertList(shouldShowLoading: true)
      case .failure(let failure):
        self.logger.error("Delete alert error: \(failure.customMessage)")
      }
    }
  }
  
  private func updatePriceAlert(
    id: String,
    tokenId: String,
    symbol: String,
    deviceId: String,
    discordId: String,
    priceSet: Double,
    trend: PriceTrend,
    isEnable: Bool
  ) {
    guard !discordId.isEmpty else {
      return
    }
    
    Task(priority: .high) {
      self.isLoading = true
      
      let result = await alertService.upsertPriceAlert(
        id: id,
        deviceId: deviceId,
        discordId: discordId,
        tokenId: tokenId,
        symbol: symbol,
        priceSet: priceSet,
        trend: trend,
        isEnable: isEnable
      )
      
      self.isLoading = false
      
      switch result {
      case .success:
        logger.info("Edit price alert success!")
        self.fetchAlertList(shouldShowLoading: true)
      case .failure(let failure):
        logger.error("Edit price alert failed, error: \(failure.customMessage)")
      }
    }
  }
}

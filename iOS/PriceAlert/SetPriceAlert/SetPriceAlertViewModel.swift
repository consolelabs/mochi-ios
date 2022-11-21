//
//  SetPriceAlertViewModel.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 18/11/2022.
//

import Foundation
import SwiftUI
import OSLog

class SetPriceAlertViewModel: ObservableObject {
  private let logger = Logger(subsystem: "so.console.mochi", category: "SetPriceAlertViewModel")
  private let alertService: PriceAlertService
  
  @Published var isLoading: Bool = false
  @Published var data: [AlertPresenter] = []
  @Published var priceTrend: PriceTrend = .up
  @Published var prices: [Double]
  @Published var currentPrice: Double
  @Published var tokenName: String
  @Published var tokenSymbol: String
  @Published var shouldDismiss: Bool = false
  @Published var showError: Bool = false
  @Published var errorMessage: String = ""

  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""
 
  private let tokenId: String
  private let price: Double
  
  init(
    alertService: PriceAlertService,
    tokenId: String,
    tokenName: String,
    tokenSymbol: String,
    price: Double
  ) {
    self.alertService = alertService
    self.tokenId = tokenId
    self.tokenName = tokenName
    self.tokenSymbol = tokenSymbol
    self.price = price
    self.currentPrice = price
    self.prices = (0...200).map { step -> Double in
      return Double(Double(step) * price / 100)
    }
  }
  
  func setPriceAlert() {
    guard !discordId.isEmpty else {
      self.errorMessage = "Please set your Discord ID in Settings tab first!"
      self.showError = true
      return
    }
    
    Task(priority: .high) {
      await MainActor.run {
        self.isLoading = true
      }
      let deviceId = await UIDevice().identifierForVendor?.uuidString ?? ""
      let result = await alertService.upsertPriceAlert(
        deviceId: deviceId,
        discordId: discordId,
        tokenId: tokenId,
        priceSet: currentPrice,
        trend: priceTrend
      )
      await MainActor.run {
        self.isLoading = false
        self.shouldDismiss = true
      }
      switch result {
      case .success:
        logger.info("Set new price alert success!")
      case .failure(let failure):
        logger.error("Set new price alert failed, error: \(failure.customMessage)")
      }
    }
  }
}

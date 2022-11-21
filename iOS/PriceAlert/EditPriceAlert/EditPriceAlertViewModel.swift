//
//  EditPriceAlertViewModel.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 18/11/2022.
//

import Foundation
import SwiftUI
import OSLog

struct EditPriceAlertParam {
  let id: String
  let tokenId: String
  let tokenName: String
  let tokenSymbol: String
  let price: Double
  let isEnable: Bool
  let trend: PriceTrend
}

class EditPriceAlertViewModel: ObservableObject {
  private let logger = Logger(subsystem: "so.console.mochi", category: "EditPriceAlertViewModel")
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
  
  init(
    alertService: PriceAlertService,
    priceAlert: EditPriceAlertParam
  ) {
    self.alertService = alertService
    self.tokenId = priceAlert.tokenId
    self.tokenName = priceAlert.tokenName
    self.tokenSymbol = priceAlert.tokenSymbol
    self.currentPrice = priceAlert.price
    self.prices = (0...200).map { step -> Double in
      return Double(Double(step) * priceAlert.price / 100)
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
        logger.info("Edit price alert success!")
      case .failure(let failure):
        logger.error("Edit price alert failed, error: \(failure.customMessage)")
      }
    }
  }
}
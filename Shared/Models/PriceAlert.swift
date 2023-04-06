//
//  PriceAlert.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 06/04/2023.
//

import Foundation

enum AlertType: String, Codable, CaseIterable {
  case priceReaches     = "price_reaches"
  case priceRisesAbove  = "price_rises_above"
  case priceDropsTo     = "price_drops_to"
  case changeIsOver     = "change_is_over"
  case changeIsUnder    = "change_is_under"
}

enum AlertFrequency: String, Codable, CaseIterable {
  case onlyOnce = "only_once"
  case onceADay = "once_a_day"
  case always   = "always"
}

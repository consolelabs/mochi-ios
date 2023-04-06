//
//  Double+Formatter.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 22/03/2023.
//

import Foundation

extension Double {
  func toPriceFormat(withoutSymbol: Bool = true) -> String? {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.currencyCode = "USD"
    numberFormatter.currencySymbol = ""
    numberFormatter.maximumFractionDigits = 3
    numberFormatter.currencySymbol = withoutSymbol ? "" : "$"
    return numberFormatter.string(from: NSNumber(value: self))
  }
}

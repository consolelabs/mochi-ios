//
//  Data+utils.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 24/03/2023.
//

import Foundation

extension Data {
  public func toHexString() -> String {
    return map({ String(format: "%02x", $0) }).joined()
  }
}

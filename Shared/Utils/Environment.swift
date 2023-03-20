//
//  Environment.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 20/03/2023.
//

import Foundation

public enum AppEnvironment {
  private static let infoDictionary: [String: Any] = {
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("Plist file not found")
    }
    return dict
  }()

  static let moralisApiKey: String = {
    if let key = ProcessInfo.processInfo.environment["MORALIS_API_KEY"] {
      return key
    }
    if let key = AppEnvironment.infoDictionary["MORALIS_API_KEY"] as? String {
      return key
    }
    return ""
  }()
}

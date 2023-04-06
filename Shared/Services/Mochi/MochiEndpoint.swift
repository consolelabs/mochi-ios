//
//  MochiEndpoint.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 03/04/2023.
//

import Foundation

enum MochiEndpoint {
  case getUserPriceAlert(discordID: String, page: Int, size: Int)
  case createPriceAlert(request: CreatePriceAlertRequest)
  case deletePriceAlert(symbol: String, discordID: String)
  
  case getBinanceCoin(symbol: String)
}

extension MochiEndpoint: Endpoint {
  var host: String {
    return "api.mochi.pod.town"
  }
  
  var path: String {
    switch self {
    case .getUserPriceAlert, .createPriceAlert, .deletePriceAlert:
      return "/api/v1/defi/price-alert"
    case let .getBinanceCoin(symbol):
      return "/api/v1/defi/coins/binance/\(symbol)"
    }
  }
  
  var method: RequestMethod {
    switch self {
    case .getUserPriceAlert, .getBinanceCoin:
      return .get
    case .createPriceAlert:
      return .post
    case .deletePriceAlert:
      return .delete
    }
  }
  
  var header: [String: String]? {
    return [
      "Content-Type": "application/json;charset=utf-8"
    ]
  }
    
  var body: [String: Any]? {
    switch self {
    case let .createPriceAlert(request):
      return request.dictionary
    case let .deletePriceAlert(symbol, discordID):
      return [
        "symbol": symbol,
        "user_id": discordID
      ]
      
    case .getUserPriceAlert, .getBinanceCoin:
      return nil
    }
  }
  
  var parameters: [String: String]? {
    switch self {
    case let .getUserPriceAlert(discordID, page, size):
      let params = [
        "user_discord_id": discordID,
        "page": "\(page)",
        "size": "\(size)"
      ]
      return params
    case .createPriceAlert, .deletePriceAlert, .getBinanceCoin:
      return nil
    }
  }
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

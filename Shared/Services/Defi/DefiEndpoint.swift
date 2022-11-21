//
//  DefiEndpoint.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import Foundation

enum DefiEndpoint {
  case queryCoins(query: String)
  case getCoin(id: String)
  case watchlist(page: Int? = 0, pageSize: Int? = 10, userId: String)
  case addWatchlist(coinId: String, userId: String)
  case removeWatchlist(symbol: String, userId: String)
}

extension DefiEndpoint: Endpoint {
  var host: String {
    return "api.mochi.pod.town"
  }
  
  var path: String {
    switch self {
    case .queryCoins:
      return "/api/v1/defi/coins"
      
    case .getCoin(let id):
      return "/api/v1/defi/coins/\(id)"
      
    case .watchlist:
      return "/api/v1/defi/watchlist"
    case .addWatchlist:
      return "/api/v1/defi/watchlist"
    case .removeWatchlist:
      return "/api/v1/defi/watchlist"
    }
  }
  
  var method: RequestMethod {
    switch self {
    case .queryCoins, .getCoin, .watchlist:
      return .get
    case .addWatchlist:
      return .post
    case .removeWatchlist:
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
    case .addWatchlist(let coinId, let userId):
      return ["coin_gecko_id": coinId, "user_id": userId]
    case .queryCoins, .getCoin, .watchlist, .removeWatchlist:
      return nil
    }
  }
  
  var parameters: [String: String]? {
    switch self {
    case .queryCoins(let query):
      var params = [String: String]()
      params["query"] = query
      return params
      
    case .watchlist(let page, let pageSize, let userId):
      var params = [String: String]()
      if let page = page {
        params["page"] = "\(page)"
      }
      if let pageSize = pageSize {
        params["size"] = "\(pageSize)"
      }
      params["user_id"] = userId
      return params
      
    case .removeWatchlist(let symbol, let userId):
      return ["symbol": symbol, "user_id": userId]
      
    case .getCoin, .addWatchlist: return nil
    }
  }
}

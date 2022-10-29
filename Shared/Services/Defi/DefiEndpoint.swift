//
//  DefiEndpoint.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import Foundation

enum DefiEndpoint {
  case watchlist(page: Int? = 0, pageSize: Int? = 10, userId: String)
}

extension DefiEndpoint: Endpoint {
  var host: String {
    return "api.mochi.pod.town"
  }
  
  var path: String {
    switch self {
    case .watchlist:
      return "/api/v1/defi/watchlist"
    }
  }
  
  var method: RequestMethod {
    switch self {
    case .watchlist:
      return .get
    }
  }
  
  var header: [String: String]? {
    switch self {
    case .watchlist:
      return [
        "Content-Type": "application/json;charset=utf-8"
      ]
    }
  }
    
  var body: [String: String]? {
    switch self {
    case .watchlist:
      return nil
    }
  }
  
  var parameters: [String: String]? {
    switch self {
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
    }
  }
}

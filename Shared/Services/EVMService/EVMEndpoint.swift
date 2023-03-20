//
//  EVMEndpoint.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 20/03/2023.
//

import Foundation

enum EVMEndpoint {
  case resolveENS(address: String)
}

extension EVMEndpoint: Endpoint {
  var host: String {
    return "deep-index.moralis.io"
  }
  
  var path: String {
    switch self {
    case .resolveENS(let address):
      return "/api/v2/resolve/\(address)/reverse"
    }
  }
  
  var method: RequestMethod {
    switch self {
    case .resolveENS:
      return .get
    }
  }
  
  var header: [String: String]? {
    return [
      "Content-Type": "application/json",
      "X-API-Key": AppEnvironment.moralisApiKey
    ]
  }
  
  var body: [String: Any]? {
    switch self {
    case .resolveENS:
      return nil
    }
  }
  
  var parameters: [String: String]? {
    switch self {
    case .resolveENS: return nil
    }
  }
}

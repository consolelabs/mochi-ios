//
//  MochiProfileEndpoint.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 20/03/2023.
//

import Foundation

enum MochiProfileEndpoint {
  case getByDiscord(id: String)
}

extension MochiProfileEndpoint: Endpoint {
  var host: String {
    return "api.mochi-profile.console.so"
  }
  
  var path: String {
    switch self {
    case .getByDiscord(let discordID):
      return "/api/v1/profiles/get-by-discord/\(discordID)"
    }
  }
  
  var method: RequestMethod {
    switch self {
    case .getByDiscord:
      return .get
    }
  }
  
  var header: [String: String]? {
    return [
      "Content-Type": "application/json;charset=utf-8"
    ]
  }
  
  var body: [String: Any]? {
    switch self {
    case .getByDiscord:
      return nil
    }
  }
  
  var parameters: [String: String]? {
    switch self {
    case .getByDiscord: return nil
    }
  }
}

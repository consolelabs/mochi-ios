//
//  DiscordEndpoint.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 23/11/2022.
//

import Foundation

enum DiscordEndpoint {
  case user
}

extension DiscordEndpoint: Endpoint {
  var host: String {
    return "discord.com"
  }
  
  var path: String {
    switch self {
    case .user:
      return "/api/v10/users/@me"
    }
  }
  
  var method: RequestMethod {
    switch self {
    case .user:
      return .get
    }
  }
  
  var header: [String: String]? {
    let accessToken = UserDefaults(suiteName: "group.so.console.mochi")?.string(forKey: "discordAccessToken") ?? ""
    return [
      "Authorization": "Bearer \(accessToken)"
    ]
  }
    
  var body: [String: Any]? {
    return nil
  }
  
  var parameters: [String: String]? {
    return nil
  }
}

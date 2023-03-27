//
//  MochiProfileEndpoint.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 20/03/2023.
//

import Foundation

enum MochiProfileEndpoint {
  // Profile
  case getByDiscord(id: String)
  case getByID(id: String)
  case getMe(accessToken: String)
  
  // Auth
  case authBySolana(code: String, signature: String, walletAddress: String)
  case authByEVM(code: String, signature: String, walletAddress: String)
}

extension MochiProfileEndpoint: Endpoint {
  var host: String {
    return "api.mochi-profile.console.so"
  }
  
  var path: String {
    switch self {
    case .getByDiscord(let discordID):
      return "/api/v1/profiles/get-by-discord/\(discordID)"
    case .getByID(let id):
      return "/api/v1/profiles/\(id)"
    case .getMe:
      return "/api/v1/profiles/me"
    case .authBySolana:
      return "/api/v1/profiles/auth/solana"
    case .authByEVM:
      return "/api/v1/profiles/auth/evm"
    }
  }
  
  var method: RequestMethod {
    switch self {
    case .getByDiscord, .getByID, .getMe:
      return .get
    case .authBySolana, .authByEVM:
      return .post
    }
  }
  
  var header: [String: String]? {
    switch self {
    case .getMe(let accessToken):
      return [
        "Content-Type": "application/json;charset=utf-8",
        "Authorization": accessToken
      ]
    default:
      return [
        "Content-Type": "application/json;charset=utf-8"
      ]
    }
  }
  
  var body: [String: Any]? {
    switch self {
    case let .authBySolana(code, signature, walletAddress):
      return [
        "code": code,
        "signature": signature,
        "wallet_address": walletAddress
      ]
    case let .authByEVM(code, signature, walletAddress):
      return [
        "code": code,
        "signature": signature,
        "wallet_address": walletAddress
      ]
    default:
      return nil
    }
  }
  
  var parameters: [String: String]? {
    switch self {
    default:
      return nil
    }
  }
}

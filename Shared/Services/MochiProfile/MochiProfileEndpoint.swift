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
  case updateInfo(accessToken: String, avatar: String, profileName: String)
  case uploadImage(accessToken: String, data: [UInt8], imageName: String)
  
  // Auth
  case authBySolana(code: String, signature: String, walletAddress: String)
  case authByEVM(code: String, signature: String, walletAddress: String)
  
  // Activities
  case getActivities(profileId: String, page: Int, size: Int)
  case readActivities(profileId: String, ids: [Int])
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
    case .getActivities(let profileId, _, _):
      return "/api/v1/profiles/\(profileId)/activities"
    case .readActivities(let profileId, _):
      return "/api/v1/profiles/\(profileId)/activities"
    case .updateInfo:
      return "/api/v1/profiles/me/info"
    case .uploadImage:
      return "/api/v1/gcs/upload-images"
    }
  }
  
  var method: RequestMethod {
    switch self {
    case .getByDiscord, .getByID, .getMe, .getActivities:
      return .get
    case .authBySolana, .authByEVM, .uploadImage:
      return .post
    case .readActivities, .updateInfo:
      return .put
    }
  }
  
  var header: [String: String]? {
    switch self {
    case .getMe(let accessToken):
      return [
        "Content-Type": "application/json;charset=utf-8",
        "Authorization": "Bearer \(accessToken)"
      ]
    case .updateInfo(let accessToken, _, _):
      return [
        "Content-Type": "application/json;charset=utf-8",
        "Authorization": "Bearer \(accessToken)"
      ]
    case .uploadImage(let accessToken, _, _):
      return [
        "Content-Type": "application/json;charset=utf-8",
        "Authorization": "Bearer \(accessToken)"
      ]
    case .getByDiscord, .getByID, .authByEVM, .authBySolana, .getActivities, .readActivities:
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
    case let .readActivities(profileId: _, ids: ids):
      return [
        "ids": ids
      ]
    case .getByDiscord, .getByID, .getMe, .getActivities:
      return nil
    case let .updateInfo(_, avatar, profileName):
      var req: [String: Any] = [:]
      if !avatar.isEmpty {
          req["avatar"] = avatar
      }
      if !profileName.isEmpty {
        req["profile_name"] = profileName
      }
      return req
    case .uploadImage(_, data: let data, imageName: let imageName):
      var req: [String: Any] = [
        "image_name": UUID().uuidString
      ]
      if !imageName.isEmpty {
          req["image_name"] = imageName
      }
      req["data"] = data
      return req
    }
  }
  
  var parameters: [String: String]? {
    switch self {
    case .getByDiscord:
      return nil
    case .getByID:
      return nil
    case .getMe:
      return nil
    case .authBySolana:
      return nil
    case .authByEVM:
      return nil
    case .getActivities(_, let page, let size):
      return [
        "page": "\(page)",
        "size": "\(size)"
      ]
    case .readActivities:
      return nil
    case .updateInfo:
      return nil
    case .uploadImage:
      return nil
    }
  }
}

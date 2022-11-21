//
//  PriceAlertEndpoint.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 17/11/2022.
//

import Foundation

enum PriceAlertEndpoint {
  case upsertUserDevicePushToken(deviceId: String, pushToken: String)
  case getUserPriceAlert(discordId: String)
  case upsertPriceAlert(id: String?,
                        deviceId: String,
                        discordId: String,
                        tokenId: String,
                        priceSet: Double,
                        trend: PriceTrend,
                        isEnable: Bool?)
  case deletePriceAlert(id: String)
}

extension PriceAlertEndpoint: Endpoint {
  var host: String {
    return "api.mochi.pod.town"
  }
  
  var path: String {
    switch self {
    case .upsertUserDevicePushToken:
      return "/api/v1/users/device"
      
    case .getUserPriceAlert, .upsertPriceAlert, .deletePriceAlert:
      return "/api/v1/configs/token-alert"
    }
  }
  
  var method: RequestMethod {
    switch self {
    case .getUserPriceAlert:
      return .get
    case .upsertPriceAlert, .upsertUserDevicePushToken:
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
    case .upsertUserDevicePushToken(let deviceId, let pushToken):
      return [
        "device_id": deviceId,
        "ios_noti_token": pushToken
      ]

    case let .upsertPriceAlert(id,
                               deviceId,
                               discordId,
                               tokenId,
                               priceSet,
                               trend,
                               isEnable):
      var dict: [String: Any] = [
        "device_id": deviceId,
        "discord_id": discordId,
        "token_id": tokenId,
        "price_set": priceSet,
        "trend": trend.rawValue,
      ]
      if let id {
        dict["id"] = id
      }
      if let isEnable {
        dict["is_enable"] = isEnable
      }
      return dict
      
    case .deletePriceAlert(let id):
      return ["id": id]
      
    case .getUserPriceAlert:
      return nil
    }
  }
  
  var parameters: [String: String]? {
    switch self {
    case .getUserPriceAlert(let discordId):
      let params = ["discord_id": discordId]
      return params
    case .upsertPriceAlert, .upsertUserDevicePushToken, .deletePriceAlert:
      return nil
    }
  }
}


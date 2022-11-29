//
//  PriceAlertService.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 17/11/2022.
//

import Foundation

protocol PriceAlertService {
  func upsertUserDevicePushToken(deviceId: String, pushToken: String) async -> Result<UpsertUserDevicePushTokenResponse, RequestError>
  func getUserPriceAlert(discordId: String) async -> Result<GetUserPriceAlertResponse, RequestError>
  func upsertPriceAlert(
    id: String?,
    deviceId: String,
    discordId: String,
    tokenId: String,
    symbol: String,
    priceSet: Double,
    trend: PriceTrend,
    isEnable: Bool?
  ) async -> Result<UpsertPriceAlertResponse, RequestError>
  func deletePriceAlert(id: String) async -> Result<DeletePriceAlertResponse, RequestError>
}

extension PriceAlertService {
  func upsertPriceAlert(
    id: String? = nil,
    deviceId: String,
    discordId: String,
    tokenId: String,
    symbol: String,
    priceSet: Double,
    trend: PriceTrend,
    isEnable: Bool? = true
  ) async -> Result<UpsertPriceAlertResponse, RequestError> {
    return await self.upsertPriceAlert(id: id,
                                       deviceId: deviceId,
                                       discordId: discordId,
                                       tokenId: tokenId,
                                       symbol: symbol,
                                       priceSet: priceSet,
                                       trend: trend,
                                       isEnable: isEnable)
  }
}

final class PriceAlertServiceImpl: HTTPClient, PriceAlertService {
  func upsertUserDevicePushToken(
    deviceId: String,
    pushToken: String
  ) async -> Result<UpsertUserDevicePushTokenResponse, RequestError> {
    return await sendRequest(
      endpoint: PriceAlertEndpoint.upsertUserDevicePushToken(deviceId: deviceId, pushToken: pushToken),
      responseModel: UpsertUserDevicePushTokenResponse.self)
  }
  
  func getUserPriceAlert(discordId: String) async -> Result<GetUserPriceAlertResponse, RequestError> {
    return await sendRequest(
      endpoint: PriceAlertEndpoint.getUserPriceAlert(discordId: discordId),
      responseModel: GetUserPriceAlertResponse.self)
  }
  
  func upsertPriceAlert(
    id: String?,
    deviceId: String,
    discordId: String,
    tokenId: String,
    symbol: String,
    priceSet: Double,
    trend: PriceTrend,
    isEnable: Bool?
  ) async -> Result<UpsertPriceAlertResponse, RequestError> {
    return await sendRequest(
      endpoint: PriceAlertEndpoint.upsertPriceAlert(id: id,
                                                    deviceId: deviceId,
                                                    discordId: discordId,
                                                    tokenId: tokenId,
                                                    symbol: symbol,
                                                    priceSet: priceSet,
                                                    trend: trend,
                                                    isEnable: isEnable),
      responseModel: UpsertPriceAlertResponse.self)
  }
  
  func deletePriceAlert(id: String) async -> Result<DeletePriceAlertResponse, RequestError> {
    return await sendRequest(endpoint: PriceAlertEndpoint.deletePriceAlert(id: id),
                             responseModel: DeletePriceAlertResponse.self)
  }
}

struct UpsertUserDevicePushTokenResponse: Codable {
  struct Data: Codable {
    let message: String
  }
  let data: Data
}

struct UserDevice: Codable {
  let id: String
  let iosNotiToken: String
  
  private enum CodingKeys: String, CodingKey {
    case id
    case iosNotiToken = "ios_noti_token"
  }
}

enum PriceTrend: String, Codable {
  case up
  case down
}

struct GetUserPriceAlertResponse: Codable {
  struct PriceAlert: Codable {
    let id: String
    let discordId: String
    let deviceId: String
    let isEnable: Bool
    let priceSet: Double
    let tokenId: String
    let symbol: String
    let trend: PriceTrend
    let device: UserDevice
    
    private enum CodingKeys: String, CodingKey {
      case id
      case trend
      case device
      case tokenId = "token_id"
      case symbol = "symbol"
      case discordId = "discord_id"
      case deviceId = "device_id"
      case isEnable = "is_enable"
      case priceSet = "price_set"
    }
  }
  
  let data: [PriceAlert]
}

struct UpsertPriceAlertResponse: Codable {
  struct Data: Codable {
    let message: String
  }
  let data: Data
}

struct DeletePriceAlertResponse: Codable {
  struct Data: Codable {
    let message: String
  }
  let data: Data
}

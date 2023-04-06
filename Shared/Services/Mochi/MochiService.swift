//
//  MochiService.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 03/04/2023.
//

import Foundation

protocol MochiService {
  func getPriceAlert(discordID: String, page: Int, size: Int) async -> Result<GetPriceAlertResponse, RequestError>
  func createPriceAlert(request: CreatePriceAlertRequest) async -> Result<CreatePriceAlertResponse, RequestError>
  func deletePriceAlert(symbol: String, discordID: String) async -> Result<MochiDeletePriceAlertResponse, RequestError>
  func getBinanceCoin(symbol: String) async -> Result<GetBinanceCoinResponse, RequestError>
}

extension MochiService {
  func getPriceAlert(discordID: String) async -> Result<GetPriceAlertResponse, RequestError> {
    return await self.getPriceAlert(discordID: discordID, page: 0, size: 100)
  }
}

final class MochiServiceImpl: MochiService, HTTPClient {
  func createPriceAlert(request: CreatePriceAlertRequest) async -> Result<CreatePriceAlertResponse, RequestError> {
    return await sendRequest(
      endpoint: MochiEndpoint.createPriceAlert(request: request),
      responseModel: CreatePriceAlertResponse.self
    )
  }
  
  func deletePriceAlert(symbol: String, discordID: String) async -> Result<MochiDeletePriceAlertResponse, RequestError> {
    return await sendRequest(
      endpoint: MochiEndpoint.deletePriceAlert(symbol: symbol, discordID: discordID),
      responseModel: MochiDeletePriceAlertResponse.self
    )
  }
  
  func getPriceAlert(discordID: String, page: Int, size: Int) async -> Result<GetPriceAlertResponse, RequestError> {
    return await sendRequest(
      endpoint: MochiEndpoint.getUserPriceAlert(discordID: discordID, page: page, size: size),
      responseModel: GetPriceAlertResponse.self
    )
  }
  
  func getBinanceCoin(symbol: String) async -> Result<GetBinanceCoinResponse, RequestError> {
      return await sendRequest(
        endpoint: MochiEndpoint.getBinanceCoin(symbol: symbol),
        responseModel: GetBinanceCoinResponse.self
      )
  }
}



struct GetPriceAlertResponse: Codable {
  let data: [UserTokenPriceAlert]
}

struct CreatePriceAlertResponse: Codable {
}

struct MochiDeletePriceAlertResponse: Codable {
  
}

struct CreatePriceAlertRequest: Encodable {
  let alertType: AlertType
  let frequency: AlertFrequency
  let priceByPercent: Double
  let symbol: String
  let userDiscordID: String
  let value: Double
  
  private enum CodingKeys: String, CodingKey {
    case symbol
    case frequency
    case value
    case userDiscordID = "user_discord_id"
    case alertType = "alert_type"
    case priceByPercent = "price_by_percent"
  }
}

struct UserTokenPriceAlert: Codable {
  let id: Int
  let userDiscordID: String
  let symbol: String
  let currency: String
  let alertType: AlertType
  let frequency: AlertFrequency
  let value: Double
  let priceByPercent: Double
//  let snoozedTo: Date
//  let createdAt: Date
//  let updatedAt: Date
  
  private enum CodingKeys: String, CodingKey {
    case id
    case symbol
    case currency
    case frequency
    case value
    case userDiscordID = "user_discord_id"
    case alertType = "alert_type"
    case priceByPercent = "price_by_percent"
//    case snoozedTo = "snoozed_to"
//    case createdAt = "created_at"
//    case updatedAt = "updated_at"
  }
}

struct GetBinanceCoinResponse: Codable {
  struct Data: Codable {
    let symbol: String
    let price: String
  }
  let data: Data
}

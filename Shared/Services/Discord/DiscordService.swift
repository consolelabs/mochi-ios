//
//  DiscordService.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 23/11/2022.
//

import Foundation

protocol DiscordService {
  func getCurrentUser() async -> Result<GetCurrentUserResponse, RequestError>
}

final class DiscordServiceImpl: HTTPClient, DiscordService {
  func getCurrentUser() async -> Result<GetCurrentUserResponse, RequestError> {
    return await sendRequest(endpoint: DiscordEndpoint.user, responseModel: GetCurrentUserResponse.self)
  }
}

struct GetCurrentUserResponse: Codable {
  let id: String
  let username: String
  let avatar: String?
  let discriminator: String
}

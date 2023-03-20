//
//  MochiProfileService.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 20/03/2023.
//

import Foundation

protocol MochiProfileService {
  func getByDiscord(id: String) async -> Result<GetByDiscordResponse, RequestError>
}

final class MochiProfileServiceImp: HTTPClient, MochiProfileService {
  func getByDiscord(id: String) async -> Result<GetByDiscordResponse, RequestError> {
    return await sendRequest(
      endpoint: MochiProfileEndpoint.getByDiscord(id: id),
      responseModel: GetByDiscordResponse.self
    )
  }
}

struct GetByDiscordResponse: Codable {
  struct AssociatedAccount: Codable {
    enum Platform: String, Codable {
      case discord = "discord"
      case solanaChain = "solana-chain"
      case evmChain = "evm-chain"
    }
    
    let id: String
    let profileID: String
    let platform: Platform?
    let platformIdentifier: String
    
    private enum CodingKeys: String, CodingKey {
      case id
      case profileID = "profile_id"
      case platform = "platform"
      case platformIdentifier = "platform_identifier"
    }
  }
  
  let id: String
  let associatedAccounts: [AssociatedAccount]
  
  private enum CodingKeys: String, CodingKey {
    case id
    case associatedAccounts = "associated_accounts"
  }
}

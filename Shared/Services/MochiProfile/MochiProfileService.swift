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

@propertyWrapper
public struct NilOnFailCodable<ValueType>: Codable where ValueType: Codable {

    public var wrappedValue: ValueType?

    public init(wrappedValue: ValueType?) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        self.wrappedValue = try? ValueType(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = wrappedValue {
            try container.encode(value)
        } else {
            try container.encodeNil()
        }
    }
}

struct GetByDiscordResponse: Codable {
  struct AssociatedAccount: Codable {
    enum Platform: String, Codable {
      case telegram = "telegram"
      case discord = "discord"
      case solanaChain = "solana-chain"
      case evmChain = "evm-chain"
    }
    
    let id: String
    let profileID: String
    
    @NilOnFailCodable
    var platform: Platform?
    
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

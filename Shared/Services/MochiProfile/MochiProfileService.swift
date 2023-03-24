//
//  MochiProfileService.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 20/03/2023.
//

import Foundation

protocol MochiProfileService {
  // Profile
  func getByDiscord(id: String) async -> Result<GetProfileResponse, RequestError>
  func getByID(id: String) async -> Result<GetProfileResponse, RequestError>
  func getMe() async -> Result<GetProfileResponse, RequestError>

  // Auth
  func authBySolana(code: String, signature: String, walletAddress: String) async -> Result<AuthBySolanaResponse, RequestError>
}

final class MochiProfileServiceImp: HTTPClient, MochiProfileService {
  private let keyChainService: KeychainService
    
  init(keychainService: KeychainService) {
    self.keyChainService = keychainService
  }
  
  func getByDiscord(id: String) async -> Result<GetProfileResponse, RequestError> {
    return await sendRequest(
      endpoint: MochiProfileEndpoint.getByDiscord(id: id),
      responseModel: GetProfileResponse.self
    )
  }
  
  func getByID(id: String) async -> Result<GetProfileResponse, RequestError> {
    return await sendRequest(
      endpoint: MochiProfileEndpoint.getByID(id: id),
      responseModel: GetProfileResponse.self
    )
  }
  
  func getMe() async -> Result<GetProfileResponse, RequestError> {
    guard let accessToken = try? keyChainService.getString("accessToken") else {
      return .failure(.unauthorized)
    }
    return await sendRequest(
      endpoint: MochiProfileEndpoint.getMe(accessToken: accessToken),
      responseModel: GetProfileResponse.self
    )
  }
  
  func authBySolana(code: String, signature: String, walletAddress: String) async -> Result<AuthBySolanaResponse, RequestError> {
    return await sendRequest(
      endpoint: MochiProfileEndpoint.authBySolana(code: code, signature: signature, walletAddress: walletAddress),
      responseModel: AuthBySolanaResponse.self
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


enum Platform: String, Codable {
  case telegram = "telegram"
  case discord = "discord"
  case solanaChain = "solana-chain"
  case evmChain = "evm-chain"
}

struct AssociatedAccount: Codable {
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

struct GetByDiscordResponse: Codable {
  let id: String
  let profileName: String
  let avatar: String
  let associatedAccounts: [AssociatedAccount]
  
  private enum CodingKeys: String, CodingKey {
    case id
    case associatedAccounts = "associated_accounts"
    case profileName = "profile_name"
    case avatar = "avatar"
  }
}

struct GetProfileResponse: Codable {
  let id: String
  let associatedAccounts: [AssociatedAccount]
  let profileName: String
  let avatar: String
  
  private enum CodingKeys: String, CodingKey {
    case id
    case associatedAccounts = "associated_accounts"
    case profileName = "profile_name"
    case avatar = "avatar"
  }
}

struct AuthBySolanaResponse: Codable {
  struct Data: Codable {
    let accessToken: String
    private enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
    }
  }
    
  let data: Data
}

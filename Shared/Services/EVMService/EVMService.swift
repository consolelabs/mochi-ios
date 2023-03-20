//
//  EVMService.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 20/03/2023.
//

import Foundation

protocol EVMService {
  func resolveENS(address: String) async -> Result<ResolveENSResponse, RequestError>
}

final class EVMServiceImp: HTTPClient, EVMService {
  func resolveENS(address: String) async -> Result<ResolveENSResponse, RequestError> {
    return await sendRequest(endpoint: EVMEndpoint.resolveENS(address: address), responseModel: ResolveENSResponse.self)
  }
}


struct ResolveENSResponse: Codable {
  let name: String?
}

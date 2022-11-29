//
//  RequestError.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import Foundation

enum RequestError: Error {
  case decode(error: String)
  case invalidURL
  case noResponse
  case unauthorized
  case unexpectedStatusCode
  case unknown(error: String)
  
  var customMessage: String {
    switch self {
    case .decode(let error):
      return "Decode error: \(error)"
    case .unauthorized:
      return "Session expired"
    case .invalidURL:
      return "Invalid URL"
    case .noResponse:
      return "No response"
    case .unexpectedStatusCode:
      return "Unexpected Status Code"
    case .unknown(let error):
      return error
    }
  }
}

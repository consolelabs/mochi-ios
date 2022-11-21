//
//  Endpoint.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import Foundation

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
    var body: [String: Any]? { get }
    var parameters: [String: String]? { get }
}

extension Endpoint {
  var scheme: String {
    return "https"
  }
}

extension URLComponents {
  mutating func setQueryItems(with parameters: [String: String]) {
    self.queryItems = parameters.map {
      URLQueryItem(name: $0.key, value: $0.value)
    }
  }
}

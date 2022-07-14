//
//  NetworkService.swift
//  Bitsfi
//
//  Created by Oliver Le on 30/06/2022.
//

import Foundation
import Combine

struct APIError: Decodable, Error {
  
}

final class NetworkService {
  func fetchURL<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error> {
    let urlRequest = URLRequest(url: url)
    return fetchURL(urlRequest)
  }
  
  func fetchURL<T: Decodable>(_ request: URLRequest, config: URLSessionConfiguration? = nil) -> AnyPublisher<T, Error> {
    var urlSession = URLSession.shared
    if let config = config {
      urlSession = URLSession(configuration: config)
    }
    
    return urlSession.dataTaskPublisher(for: request)
      .tryMap({ result in
        let decoder = JSONDecoder()
        guard let urlResponse = result.response as? HTTPURLResponse,
              (200...299).contains(urlResponse.statusCode) else {
          print("START Data response failure")
          print(String(data: result.data, encoding: .utf8) ?? "")
          print("END Data response failure")
          let apiError = try decoder.decode(APIError.self, from: result.data)
          throw apiError
        }
        
        print("START Data response")
        print(String(data: result.data, encoding: .utf8) ?? "")
        print("END Data response")
        return try decoder.decode(T.self, from: result.data)
      })
      .eraseToAnyPublisher()
  }
}

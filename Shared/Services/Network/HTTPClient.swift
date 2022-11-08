//
//  HTTPClient.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import Foundation

protocol HTTPClient {
  func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, RequestError>
}

extension HTTPClient {
  func sendRequest<T: Decodable>(
    endpoint: Endpoint,
    responseModel: T.Type
  ) async -> Result<T, RequestError> {
    var urlComponents = URLComponents()
    urlComponents.scheme = endpoint.scheme
    urlComponents.host = endpoint.host
    urlComponents.path = endpoint.path
    if let parameters = endpoint.parameters {
      urlComponents.setQueryItems(with: parameters)
    }
    guard let url = urlComponents.url else {
      return .failure(.invalidURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    request.allHTTPHeaderFields = endpoint.header
    
    if let body = endpoint.body {
      request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    print(request.cURLDescription())
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
      guard let response = response as? HTTPURLResponse else {
        return .failure(.noResponse)
      }
      switch response.statusCode {
      case 200...299:
        guard let decodedResponse = try? JSONDecoder().decode(responseModel, from: data) else {
          return .failure(.decode)
        }
        return .success(decodedResponse)
      case 401:
        return .failure(.unauthorized)
      default:
        return .failure(.unexpectedStatusCode)
      }
    } catch {
      return .failure(.unknown)
    }
  }
}

extension URLRequest {
    public func cURLDescription() -> String {
        guard let url = url, let method = httpMethod else {
            return "$ curl command generation failed"
        }
        var components = ["curl -v"]
        components.append("-X \(method)")
        for header in allHTTPHeaderFields ?? [:] {
            let escapedValue = header.value.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-H \"\(header.key): \(escapedValue)\"")
        }
        if let httpBodyData = httpBody {
            let httpBody = String(decoding: httpBodyData, as: UTF8.self)
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-d \"\(escapedBody)\"")
        }
        components.append("\"\(url.absoluteString)\"")
        return components.joined(separator: " \\\n\t")
    }
}

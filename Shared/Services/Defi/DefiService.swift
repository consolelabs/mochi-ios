//
//  DefiService.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 25/10/2022.
//

import Foundation

protocol DefiService {
  func queryCoins(query: String) async -> Result<SearchCoinsResponse, RequestError>
  func getCoin(id: String) async -> Result<GetCoinResponse, RequestError>
  func getWatchlist(page: Int?, pageSize: Int?, userId: String) async -> Result<GetWatchListResponse, RequestError>
  func addWatchlist(coinId: String, userId: String) async -> Result<AddWatchListResponse, RequestError>
  func removeWatchlist(symbol: String, userId: String) async -> Result<RemoveWatchListResponse, RequestError>
}

extension DefiService {
  func getWatchlist(page: Int? = 0, pageSize: Int? = 10, userId: String) async -> Result<GetWatchListResponse, RequestError> {
    return await getWatchlist(page: page, pageSize: pageSize, userId: userId)
  }
}

final class DefiServiceImpl: HTTPClient, DefiService {
  func queryCoins(query: String) async -> Result<SearchCoinsResponse, RequestError> {
    return await sendRequest(endpoint: DefiEndpoint.queryCoins(query: query), responseModel: SearchCoinsResponse.self)
  }
  
  func getCoin(id: String) async -> Result<GetCoinResponse, RequestError> {
    return await sendRequest(endpoint: DefiEndpoint.getCoin(id: id), responseModel: GetCoinResponse.self)
  }
  
  func getWatchlist(
    page: Int?,
    pageSize: Int?,
    userId: String
  ) async -> Result<GetWatchListResponse, RequestError> {
    return await sendRequest(endpoint: DefiEndpoint.watchlist(page: page, pageSize: pageSize, userId: userId), responseModel: GetWatchListResponse.self)
  }
  
  func addWatchlist(coinId: String, userId: String) async -> Result<AddWatchListResponse, RequestError> {
    return await sendRequest(endpoint: DefiEndpoint.addWatchlist(coinId: coinId, userId: userId), responseModel: AddWatchListResponse.self)
  }
  
  func removeWatchlist(symbol: String, userId: String) async -> Result<RemoveWatchListResponse, RequestError> {
    return await sendRequest(endpoint: DefiEndpoint.removeWatchlist(symbol: symbol, userId: userId), responseModel: RemoveWatchListResponse.self)
  }
}

struct GetWatchListResponse: Codable {
  let data: [DefiWatchList]
}

struct AddWatchListResponse: Codable {
  let data: [String]?
}

struct RemoveWatchListResponse: Codable {
  let data: [String]?
}

struct DefiWatchList: Codable {
  let id: String
  let name: String
  let symbol: String
  let image: String
  let isPair: Bool
  let currentPrice: Double
  let priceChangePercentage24h: Double
  let priceChangePercentage7dInCurrency: Double
  let sparklineIn7d: SparklineData
  var sparklineImageUrl: String? {
    let regex = "https://assets.coingecko.com/coins/images/([0-9]+)/"
    let groups = image.groups(for: regex)
    if let coinId = groups.first?.last {
      return "https://www.coingecko.com/coins/\(coinId)/sparkline"
    }
    return nil
  }
  
  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case symbol
    case image
    case isPair = "is_pair"
    case currentPrice = "current_price"
    case priceChangePercentage24h = "price_change_percentage_24h"
    case priceChangePercentage7dInCurrency = "price_change_percentage_7d_in_currency"
    case sparklineIn7d = "sparkline_in_7d"
  }
}

struct SparklineData: Codable {
  let price: [Double]
}

extension String {
  func groups(for regexPattern: String) -> [[String]] {
    do {
      let text = self
      let regex = try NSRegularExpression(pattern: regexPattern)
      let matches = regex.matches(in: text,
                                  range: NSRange(text.startIndex..., in: text))
      return matches.map { match in
        return (0..<match.numberOfRanges).map {
          let rangeBounds = match.range(at: $0)
          guard let range = Range(rangeBounds, in: text) else {
            return ""
          }
          return String(text[range])
        }
      }
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return []
    }
  }
}

struct SearchCoinsResponse: Codable {
  struct SearchCoinsData: Codable {
    let id: String
    let name: String
    let symbol: String
  }
  
  let data: [SearchCoinsData]
}


struct GetCoinResponse: Codable {
  struct GetCoinData: Codable {
    struct Image: Codable {
      let large: String
      let small: String
      let thumb: String
    }
    
    let id: String
    let name: String
    let symbol: String
    let image: Image
  }
  
  let data: [GetCoinData]
}


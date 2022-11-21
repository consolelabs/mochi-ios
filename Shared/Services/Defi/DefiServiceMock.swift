//
//  DefiServiceMock.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 01/11/2022.
//

import Foundation

struct DefiServiceMock: DefiService {
  func queryCoins(query: String) async -> Result<SearchCoinsResponse, RequestError> {
    return .success(SearchCoinsResponse(data: []))
  }
  
  func getCoin(id: String) async -> Result<GetCoinResponse, RequestError> {
    return .success(GetCoinResponse(data: .init(id: "bitcoin",
                                                name: "Bitcoin",
                                                symbol: "BTC",
                                                image: GetCoinResponse.GetCoinData.Image(large: "", small: "", thumb: ""))))
  }
  
  func getWatchlist(page: Int?, pageSize: Int?, userId: String) async -> Result<GetWatchListResponse, RequestError> {
    let data: [DefiWatchList] = [
      DefiWatchList(id: UUID().uuidString, name: "Bitcoin", symbol: "BTC", image: "https://assets.coingecko.com/coins/images/1/thumb/bitcoin.png?1547033579", isPair: false, currentPrice: 20294, priceChangePercentage24h: -0.21, priceChangePercentage7dInCurrency: -0.23, sparklineIn7d: SparklineData(price: [])),
      DefiWatchList(id: UUID().uuidString, name: "Ethereum", symbol: "ETH", image: "https://assets.coingecko.com/coins/images/279/thumb/ethereum.png?1595348880", isPair: false, currentPrice: 1557.39, priceChangePercentage24h: -2.4, priceChangePercentage7dInCurrency: 14.1, sparklineIn7d: SparklineData(price: [])),
      DefiWatchList(id: UUID().uuidString, name: "Tether", symbol: "USDT", image: "https://assets.coingecko.com/coins/images/325/thumb/Tether-logo.png?1598003707", isPair: false, currentPrice: 0.997884, priceChangePercentage24h: -0.2, priceChangePercentage7dInCurrency: -0.22, sparklineIn7d: SparklineData(price: []))
    ]
    return .success(GetWatchListResponse(data: data))
  }
  
  func addWatchlist(coinId: String, userId: String) async -> Result<AddWatchListResponse, RequestError> {
    return .success(AddWatchListResponse(data: nil))
  }
  
  func removeWatchlist(symbol: String, userId: String) async -> Result<RemoveWatchListResponse, RequestError> {
    return .success(RemoveWatchListResponse(data: nil))
  }
}

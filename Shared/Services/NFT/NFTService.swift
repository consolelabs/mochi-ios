//
//  NFTService.swift
//  Bitsfi
//
//  Created by Oliver Le on 30/06/2022.
//

import Foundation
import Combine

enum SortOption: String {
  case vol24h = "VOLUME_24H"
  case socialAccountBuyingVol = "SOCIAL_ACCOUNTS_BUYING_VOL"
  case floorPriceChange = "FLOOR_PRICE_CHANGE"
  case smartMoneyNetInflow = "SMART_MONEY_NET_INFLOW"
  case smartMoneyNetOutflow = "SMART_MONEY_NET_OUTFLOW"
  
  var urlQueryItem: URLQueryItem {
    return URLQueryItem(name: "sort", value: self.rawValue)
  }
}

enum TimeRangeFilter: String {
  case r1d = "1D"
  case r1w = "1W"
  case r1m = "1-month"
  
  var urlQueryItem: URLQueryItem {
    return URLQueryItem(name: "timeRangeFilter", value: self.rawValue)
  }
}

protocol NFTService {
  func fetchNFTs(
    pageSize: Int?,
    sortBy: SortOption?,
    nameFilter: String?,
    timeRangeFilter: TimeRangeFilter?
  ) -> AnyPublisher<NFTDataContainer, Error>
  
  func fetchNFTFloorPrice(
    collectionId: String,
    timeRangeFilter: TimeRangeFilter?
  ) -> AnyPublisher<NFTFloorPriceChartDataContainer, Error>
  
  func fetchNFTAveragePrice(
    collectionId: String,
    timeRangeFilter: TimeRangeFilter?
  ) -> AnyPublisher<NFTAveragePriceContainer, Error>
  
  func fetchNFTSaleVol(
    collectionId: String,
    timeRangeFilter: TimeRangeFilter?
  ) -> AnyPublisher<NFTSaleVolChartDataContainer, Error>
  
  func fetchNFTHoldDuration(collectionId: String) -> AnyPublisher<NFTHoldDurationContainer, Error>
  
  func fetchNFTTopHolder(collectionId: String) -> AnyPublisher<NFTTopHolderChartDataContainer, Error>
}

extension NFTService {
  func fetchNFTs(
    pageSize: Int? = 30,
    sortBy: SortOption? = nil,
    nameFilter: String? = nil,
    timeRangeFilter: TimeRangeFilter?
  ) -> AnyPublisher<NFTDataContainer, Error> {
    self.fetchNFTs(pageSize: pageSize, sortBy: sortBy, nameFilter: nameFilter, timeRangeFilter: timeRangeFilter)
  }
  
  func fetchNFTFloorPrice(
    collectionId: String,
    timeRangeFilter: TimeRangeFilter? = nil
  ) -> AnyPublisher<NFTFloorPriceChartDataContainer, Error> {
    self.fetchNFTFloorPrice(collectionId: collectionId, timeRangeFilter: timeRangeFilter)
  }
  
  func fetchNFTAveragePrice(
    collectionId: String,
    timeRangeFilter: TimeRangeFilter?
  ) -> AnyPublisher<NFTAveragePriceContainer, Error> {
    self.fetchNFTAveragePrice(collectionId: collectionId, timeRangeFilter: timeRangeFilter)
  }
  
  func fetchNFTSaleVol(
    collectionId: String,
    timeRangeFilter: TimeRangeFilter?
  ) -> AnyPublisher<NFTSaleVolChartDataContainer, Error> {
    self.fetchNFTSaleVol(collectionId: collectionId, timeRangeFilter: timeRangeFilter)
  }
}

/**
 * curl 'https://brew.hellomoon.io/api/aggregations/nfts?pageSize=30&nameFilter=' \
 * -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36' \
 * --compressed | jq
 */
final class NFTServiceImpl: NFTService {
  
  private let networkService = NetworkService()
  private let baseURL = "https://brew.hellomoon.io/api/aggregations"
  private var sessionConfig: URLSessionConfiguration {
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"]
    return config
  }
  
  func fetchNFTs(
    pageSize: Int? = 30,
    sortBy: SortOption? = nil,
    nameFilter: String? = nil,
    timeRangeFilter: TimeRangeFilter? = nil
  ) -> AnyPublisher<NFTDataContainer, Error> {
    var queryItems = [URLQueryItem]()
    if let pageSize = pageSize {
      queryItems.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))
    }
    if let sortBy = sortBy {
      queryItems.append(sortBy.urlQueryItem)
    }
    if let nameFilter = nameFilter {
      queryItems.append(URLQueryItem(name: "nameFilter", value: nameFilter))
    }
    if let timeRangeFilter = timeRangeFilter {
      queryItems.append(timeRangeFilter.urlQueryItem)
    }
    var urlComps = URLComponents(string: "\(baseURL)/nfts")!
    urlComps.queryItems = queryItems
    let urlRequest = URLRequest(url: urlComps.url!)
    return networkService.fetchURL(urlRequest, config: sessionConfig)
  }
  
  func fetchNFTFloorPrice(
    collectionId: String,
    timeRangeFilter: TimeRangeFilter? = nil
  ) -> AnyPublisher<NFTFloorPriceChartDataContainer, Error> {
    var queryItems = [URLQueryItem(name: "collectionId", value: collectionId)]
    if let timeRangeFilter = timeRangeFilter {
      queryItems.append(timeRangeFilter.urlQueryItem)
    }
    var urlComps = URLComponents(string: "\(baseURL)/nft-floor-price")!
    urlComps.queryItems = queryItems
    let urlRequest = URLRequest(url: urlComps.url!)
    return networkService.fetchURL(urlRequest, config: sessionConfig)
  }
  
  func fetchNFTAveragePrice(
    collectionId: String,
    timeRangeFilter: TimeRangeFilter? = nil
  ) -> AnyPublisher<NFTAveragePriceContainer, Error> {
    var queryItems = [
      URLQueryItem(name: "collectionId", value: collectionId),
      URLQueryItem(name: "priceType", value: "MEAN")
    ]
    if let timeRangeFilter = timeRangeFilter {
      queryItems.append(timeRangeFilter.urlQueryItem)
    }
    var urlComps = URLComponents(string: "\(baseURL)/nft-price")!
    urlComps.queryItems = queryItems
    let urlRequest = URLRequest(url: urlComps.url!)
    return networkService.fetchURL(urlRequest, config: sessionConfig)
  }
  
  func fetchNFTSaleVol(
    collectionId: String,
    timeRangeFilter: TimeRangeFilter? = nil
  ) -> AnyPublisher<NFTSaleVolChartDataContainer, Error> {
    var queryItems = [URLQueryItem(name: "collectionId", value: collectionId)]
    if let timeRangeFilter = timeRangeFilter {
      queryItems.append(timeRangeFilter.urlQueryItem)
    }
    var urlComps = URLComponents(string: "\(baseURL)/nft-sales-volume")!
    urlComps.queryItems = queryItems
    let urlRequest = URLRequest(url: urlComps.url!)
    return networkService.fetchURL(urlRequest, config: sessionConfig)
  }
  
  func fetchNFTHoldDuration(collectionId: String) -> AnyPublisher<NFTHoldDurationContainer, Error> {
    let queryItems = [URLQueryItem(name: "collectionId", value: collectionId)]
    var urlComps = URLComponents(string: "\(baseURL)/nft-holders-by-period")!
    urlComps.queryItems = queryItems
    let urlRequest = URLRequest(url: urlComps.url!)
    return networkService.fetchURL(urlRequest, config: sessionConfig)
  }
  
  func fetchNFTTopHolder(collectionId: String) -> AnyPublisher<NFTTopHolderChartDataContainer, Error> {
    let queryItems = [URLQueryItem(name: "id", value: collectionId)]
    var urlComps = URLComponents(string: "\(baseURL)/nft-holders-by-size")!
    urlComps.queryItems = queryItems
    let urlRequest = URLRequest(url: urlComps.url!)
    return networkService.fetchURL(urlRequest, config: sessionConfig)
  }
}

struct NFTDataContainer: Decodable {
  let nfts: [NftInfo]
}

struct NftInfo: Codable {
  let id, name: String
  let sampleImageUrl: String
  let slug: String
  let supply, currentOwnerCount, avgUsdcBalance: Int?
  let avgPriceSol, avgPriceUsd: Double
  let priceChange24hSol, floorPrice: Double?
  let floorPriceChange24h: Double?
  let floorPriceChange7d: Double?
  let volume7d: Double?
  let magicEdenHolding: Int
  let magicEdenHoldingProportion, marketCapSol, marketCapUsd: Double
  let mintPriceMode: Double?
  let volume24h, volumeChange24h: Double?
  let averageWashScore, minWashScore, maxWashScore: Int?
  let washIndexDescription: String
  let smartNetflowScore: Double
  let narrative: String?
  let externalUrl: String?
  let listingCount: Int?
}

// MARK: - Floor Price
struct NFTFloorPriceChartDataContainer: Codable {
    let result: NFTFloorPriceChartResult
}

struct NFTFloorPriceChartResult: Codable {
    let name, xLabel, yLabel: String
    let data: [NFTFlorPriceChartData]
    let asOf: String
}

struct NFTFlorPriceChartData: Codable {
    let x: Int
    let y: Double
}

// MARK: - Sale Vol
struct NFTSaleVolChartDataContainer: Codable {
    let data: NFTSaleVolChartResult
}

struct NFTSaleVolChartResult: Codable {
    let name, xLabel, yLabel: String
    let data: [NFTSaleVolChartData]
    let asOf: String
}

struct NFTSaleVolChartData: Codable {
    let x: String
    let y: Double
}

// MARK: - Top Holder
struct NFTTopHolderChartDataContainer: Codable {
    let result: NFTTopHolderChartResult
}

struct NFTTopHolderChartResult: Codable {
    let name, xLabel, yLabel: String
    let data: [NFTTopHolderChartData]
    let asOf: String
}

struct NFTTopHolderChartData: Codable {
    let x: String
    let y: NFTTopHolderYValue
}

struct NFTTopHolderYValue: Codable {
    let wallets: Int
}

// MARK: - Hold duration
struct NFTHoldDurationContainer: Codable {
    let results: NFTHoldDurationResult
}

struct NFTHoldDurationResult: Codable {
    let name, xLabel, yLabel: String
    let data: [NFTHoldDurationData]
    let asOf: String
}

struct NFTHoldDurationData: Codable {
    let x: String
    let y: NFTHoldDurationYValue
}

struct NFTHoldDurationYValue: Codable {
    let walletCount: Int
}

// MARK: - NFT Average Price
struct NFTAveragePriceContainer: Codable {
    let data: NFTAveragePriceData
}

struct NFTAveragePriceData: Codable {
    let name, xLabel, yLabel: String
    let data: [NFTAveragePriceChartData]
    let asOf: String
}

struct NFTAveragePriceChartData: Codable {
    let x: String
    let y: Double
}

//
//  MarketViewModel.swift
//  Bitsfi
//
//  Created by Oliver Le on 05/07/2022.
//

import Foundation
import Combine

struct MarketDataInfo: Identifiable {
  let id: String
  let name: String
  let image: String
  let supply: Int
  let currentOwnerCount: Int
  let avgPriceToken, avgPriceUsd: Double
  let priceChange24hToken, floorPrice: Double
  let floorPriceChange24h: Double
  let floorPriceChange7d: Double
  let volume7d: Double
  let marketCapToken, marketCapUsd: Double
  let mintPriceMode: Double
  let volume24h, volumeChange24h: Double
  let averageWashScore, minWashScore, maxWashScore: Int
  let washIndexDescription: String
  let smartNetflowScore: Double
  let narrative: String
  let externalUrl: String
  let totalList: Int?
}

// ViewModelBuilder
extension MarketDataInfo {
  static let mock = MarketDataInfo(
    id: "",
    name: "",
    image: "",
    supply: 0,
    currentOwnerCount: 0,
    avgPriceToken: 0,
    avgPriceUsd: 0,
    priceChange24hToken: 0,
    floorPrice: 0,
    floorPriceChange24h: 0,
    floorPriceChange7d: 0,
    volume7d: 0,
    marketCapToken: 0,
    marketCapUsd: 0,
    mintPriceMode: 0,
    volume24h: 0,
    volumeChange24h: 0,
    averageWashScore: 0,
    minWashScore: 0,
    maxWashScore: 0,
    washIndexDescription: "",
    smartNetflowScore: 0,
    narrative: "",
    externalUrl: "",
    totalList: nil
  )
  
  init(nftInfo: NftInfo) {
    self.id = nftInfo.id
    self.name = nftInfo.name
    self.image = nftInfo.sampleImageUrl
    self.supply = nftInfo.supply ?? 0
    self.currentOwnerCount = nftInfo.currentOwnerCount ?? 0
    self.avgPriceToken = nftInfo.avgPriceSol
    self.avgPriceUsd = nftInfo.avgPriceUsd
    self.priceChange24hToken = (nftInfo.priceChange24hSol ?? 0) * 100
    self.floorPrice = nftInfo.floorPrice ?? 0
    self.floorPriceChange24h = (nftInfo.floorPriceChange24h ?? 0) * 100
    self.floorPriceChange7d = (nftInfo.floorPriceChange7d ?? 0) * 100
    self.volume7d = nftInfo.volume7d ?? 0
    self.marketCapToken = nftInfo.marketCapSol
    self.marketCapUsd = nftInfo.marketCapUsd
    self.mintPriceMode = nftInfo.mintPriceMode ?? 0
    self.volume24h = nftInfo.volume24h ?? 0
    self.volumeChange24h = (nftInfo.volumeChange24h ?? 0) * 100
    self.averageWashScore = nftInfo.averageWashScore ?? 0
    self.minWashScore = nftInfo.minWashScore ?? 0
    self.maxWashScore = nftInfo.maxWashScore ?? 0
    self.washIndexDescription = nftInfo.washIndexDescription
    self.smartNetflowScore = nftInfo.smartNetflowScore
    self.narrative = nftInfo.narrative ?? ""
    self.externalUrl = nftInfo.externalUrl ?? ""
    self.totalList = nftInfo.listingCount
  }
}

final class MarketViewModel: ObservableObject {
  
  @Published var smartMoneyInflowData: [MarketDataInfo] = []
  @Published var isLoadingSmartMoneyInflow = true
  
  @Published var topSocialBuyingData: [MarketDataInfo] = []
  @Published var isLoadingTopSocialBuying = true
  
  @Published var topMoversData: [MarketDataInfo] = []
  @Published var isLoadingTopMover = true
  
  @Published var smartMoneyOutflowData: [MarketDataInfo] = []
  @Published var isLoadingSmartMoneyOutflow = true
  
  @Published var marketTableData: [MarketDataInfo] = []
  @Published var isLoadingMarketTableData = true
  
  @Published var selectedMarketItem: MarketDataInfo? = nil
  
  @Published var searchText: String = ""
  @Published var filteredMarketData: [MarketDataInfo] = []
  
  private let nftService: NFTService
  private var subscriptions = Set<AnyCancellable>()
  
  init(nftService: NFTService) {
    self.nftService = nftService
  }
  
  func viewDidAppear() {
    fetchSmartMoneyInflow()
    fetchSmartMoneyOutflow()
    fetchTopSocialBuying()
    fetchTopMover()
    fetchTopMarketTableData()
  }
  
  func didSelectItem(_ item: MarketDataInfo) {
    selectedMarketItem = item
  }
  
  private func fetchSmartMoneyInflow() {
    nftService.fetchNFTs(pageSize: 10, sortBy: .smartMoneyNetInflow, timeRangeFilter: .r1d)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingSmartMoneyInflow = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] nftDataContainer in
        self?.smartMoneyInflowData = nftDataContainer
          .nfts
          .map(MarketDataInfo.init)
      }
      .store(in: &subscriptions)
  }
  
  private func fetchSmartMoneyOutflow() {
    nftService.fetchNFTs(pageSize: 10, sortBy: .smartMoneyNetOutflow, timeRangeFilter: .r1d)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingSmartMoneyOutflow = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] nftDataContainer in
        self?.smartMoneyOutflowData = nftDataContainer
          .nfts
          .map(MarketDataInfo.init)
      }
      .store(in: &subscriptions)
  }
  
  private func fetchTopSocialBuying() {
    nftService.fetchNFTs(pageSize: 10, sortBy: .socialAccountBuyingVol, timeRangeFilter: .r1d)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingTopSocialBuying = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] nftDataContainer in
        self?.topSocialBuyingData = nftDataContainer
          .nfts
          .map(MarketDataInfo.init)
      }
      .store(in: &subscriptions)
  }
  
  private func fetchTopMover() {
    nftService.fetchNFTs(pageSize: 10, sortBy: .floorPriceChange, timeRangeFilter: .r1d)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingTopMover = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] nftDataContainer in
        self?.topMoversData = nftDataContainer
          .nfts
          .map(MarketDataInfo.init)
      }
      .store(in: &subscriptions)
  }
  
  private func fetchTopMarketTableData() {
    nftService.fetchNFTs(pageSize: 30, sortBy: .vol24h, timeRangeFilter: .r1d)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingMarketTableData = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] nftDataContainer in
        self?.marketTableData = nftDataContainer
          .nfts
          .map(MarketDataInfo.init)
      }
      .store(in: &subscriptions)
  }
}

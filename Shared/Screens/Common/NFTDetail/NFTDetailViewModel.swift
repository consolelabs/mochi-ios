//
//  NFTDetailViewModel.swift
//  Bitsfi
//
//  Created by Oliver Le on 08/07/2022.
//

import Foundation
import Combine

class NFTDetailViewModel: ObservableObject {
  
  private let item: MarketDataInfo
  private var didFetchData = false
  private let nftService = NFTService()
  private var subscriptions = Set<AnyCancellable>()
  
  @Published var isLoadingFloorPriceChartData: Bool = true
  @Published var floorPriceChartData: [Double] = []
  
  @Published var isLoadingSaleVolChartData: Bool = true
  @Published var saleVolChartData: [(String, Double)] = []
  
  @Published var isLoadingHoldDurationChartData: Bool = true
  @Published var holdDurationChartData: [(String, Int)] = []
  
  @Published var isLoadingTopHolderChartData: Bool = true
  @Published var topHolderChartData: [(String, Int)] = []
  
  @Published var isLoadingAveragePriceData: Bool = true
  @Published var averagePriceChartData: [(String, Double)] = []
  
  var name: String {
    return item.name
  }
  
  var image: String {
    return item.image
  }
  
  var floorPriceChangeValue: Double {
    return item.floorPriceChange24h
  }
  
  var supply: String {
    return item.supply.formatted()
  }
  
  var mintPrice: String {
    return "\(item.mintPriceMode) ◎"
  }
  
  var floorPrice: String {
    return String(format: "%.2f ◎", item.floorPrice)
  }
  
  var averagePrice: String {
    return String(format: "%.2f ◎", item.avgPriceToken)
  }
  
  var vol24h: String {
    return String(format: "%.2f ◎", item.volume24h)
  }
  
  var totalList: String {
    guard let totalList = item.totalList else {
      return "TBU"
    }
    return "\(totalList)"
  }
  
  var marketCap: String {
    return item.marketCapUsd.formatted(.currency(code: "USD"))
  }
  
  var ctaTitle: String {
    return "Get \(item.name)"
  }
  
  var ctaURL: URL? {
    return URL(string: item.externalUrl)
  }
  
  init(item: MarketDataInfo) {
    self.item = item
  }
  
  func viewDidAppear() {
    fetchDataIfNeeded()
  }
  
  private func fetchDataIfNeeded() {
    guard !didFetchData else {
      return
    }
    fetchFloorPriceChartData()
    fetchSaleVolChartData()
    fetchHoldDurationChartData()
    fetchTopHolderChartData()
    fetchAveragePriceChartData()
    
    self.didFetchData = true
  }
  
  private func fetchFloorPriceChartData() {
    nftService.fetchNFTFloorPrice(collectionId: item.id, timeRangeFilter: .r1m)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingFloorPriceChartData = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] container in
        self?.floorPriceChartData = container
          .result
          .data
          .map(\.y)
      }
      .store(in: &subscriptions)
  }
  
  private func fetchHoldDurationChartData() {
    nftService.fetchNFTHoldDuration(collectionId: item.id)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingHoldDurationChartData = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] container in
        self?.holdDurationChartData = container
          .results
          .data
          .map({ data in
            let walletCount = data.y.walletCount
            let time = data.x
            return (time, walletCount)
          })
      }
      .store(in: &subscriptions)
  }
  
  private func fetchSaleVolChartData() {
    nftService.fetchNFTSaleVol(collectionId: item.id, timeRangeFilter: .r1m)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingSaleVolChartData = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] container in
        self?.saleVolChartData = container
          .data
          .data
          .map({ data in
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let date = dateFormatter.date(from: data.x)
            let formattedDate = date?.formatted(date: .abbreviated, time: .omitted) ?? "NA"
            let vol = data.y
            return (formattedDate, vol)
          })
      }
      .store(in: &subscriptions)
  }
  
  private func fetchTopHolderChartData() {
    nftService.fetchNFTTopHolder(collectionId: item.id)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingTopHolderChartData = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] container in
        self?.topHolderChartData = container
          .result
          .data
          .map({ data in
            let nftCount = data.x
            let walletCount = data.y.wallets
            return (nftCount, walletCount)
          })
      }
      .store(in: &subscriptions)
  }
  
  private func fetchAveragePriceChartData() {
    nftService.fetchNFTAveragePrice(collectionId: item.id, timeRangeFilter: .r1m)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.isLoadingAveragePriceData = false
        switch result {
        case .finished:
          break
        case .failure(let error):
          // handle error
          print(error)
          break
        }
      } receiveValue: { [weak self] container in
        self?.averagePriceChartData = container
          .data
          .data
          .map { data in
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let date = dateFormatter.date(from: data.x)
            let formattedDate = date?.formatted(date: .abbreviated, time: .omitted) ?? "NA"
            let price = data.y
            return (formattedDate,price)
          }
      }
      .store(in: &subscriptions)
  }
  
}

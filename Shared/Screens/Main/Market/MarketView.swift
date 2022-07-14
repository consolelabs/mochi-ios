//
//  MarketView.swift
//  Bitsfi
//
//  Created by Oliver Le on 17/06/2022.
//

import SwiftUI

struct MarketView: View {
  enum ListCategory {
    case trending
    case favorites
  }
  
  @State var firstAppear: Bool = true
  @State private var searchNFT: String = ""
  @State private var showNFTDetailView: Bool = false
  @State private var listCategorySelected: ListCategory = .trending
  @StateObject private var vm = MarketViewModel()
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        smartMoneyInflowSection
          .padding(.bottom)
        topSocialBuyingSection
          .padding(.bottom)
        topMoversSection
          .padding(.bottom)
        smartMoneyOutflowSection
          .padding(.bottom)
        marketDataSection
      }
    }
    .navigationBarTitle("Market")
    .searchable(text: $vm.searchText, prompt: Text("Search NFTs")) {
    }
    .sheet(item: $vm.selectedMarketItem, content: { item in
      NavigationView {
        NFTDetailView(vm: NFTDetailViewModel(item: item))
      }
    })
    .task {
      if firstAppear {
        vm.viewDidAppear()
        firstAppear = false
      }
    }
  }
  
  var smartMoneyInflowSection: some View {
    MarketItemSectionView(
      title: "Smart Money Inflow",
      isLoading: $vm.isLoadingSmartMoneyInflow,
      marketItems: $vm.smartMoneyInflowData,
      onTap: vm.didSelectItem
    )
  }
  
  var topSocialBuyingSection: some View {
    MarketItemSectionView(
      title: "Top Social Buying",
      isLoading: $vm.isLoadingTopSocialBuying,
      marketItems: $vm.topSocialBuyingData,
      onTap: vm.didSelectItem
    )
  }
  
  var topMoversSection: some View {
    MarketItemSectionView(
      title: "Top Movers",
      isLoading: $vm.isLoadingTopMover,
      marketItems: $vm.topMoversData,
      onTap: vm.didSelectItem
    )
  }
  
  var smartMoneyOutflowSection: some View {
    MarketItemSectionView(
      title: "Smart Money Outflow",
      isLoading: $vm.isLoadingSmartMoneyOutflow,
      marketItems: $vm.smartMoneyOutflowData,
      onTap: vm.didSelectItem
    )
  }
  
  var marketDataSection: some View {
    VStack(alignment: .leading) {
      Text("Lists")
        .font(.headline)
        .foregroundColor(.title)
        .padding(.leading)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          Button(action: {
            listCategorySelected = .trending
          }) {
            Text("🔥 Trending")
              .foregroundColor(listCategorySelected == .trending ? .title : .subtitle)
              .font(.body.weight(.semibold))
              .padding(.horizontal, 8)
              .padding(.vertical, 8)
              .background(
                Capsule().foregroundColor(
                  listCategorySelected == .trending ?
                  Color.neutral1 : Color.clear
                )
              )
          }
          
          Button(action: {
            listCategorySelected = .favorites
          }) {
            Text("⭐️ Favorites")
              .font(.body.weight(.semibold))
              .foregroundColor(listCategorySelected == .favorites ? .title : .subtitle)
              .padding(.horizontal, 8)
              .padding(.vertical, 8)
              .background(
                Capsule().foregroundColor(
                  listCategorySelected == .favorites ?
                  Color.neutral1 : Color.clear
                )
              )
          }
        }
        .font(.body.weight(.medium))
        .padding(.horizontal)
      }
      
      DataTableView(marketData: $vm.marketTableData, isLoading: $vm.isLoadingMarketTableData) { item in
        vm.didSelectItem(item)
      }
    }
  }
}

struct MarketItemView: View {
  private let imageUrl: String
  private let title: String
  private let price: String
  private let priceChange: Float
  
  init(imageUrl: String, title: String, price: String, priceChange: Float) {
    self.imageUrl = imageUrl
    self.title = title
    self.price = price
    self.priceChange = priceChange
  }
  
  var body: some View {
    HStack {
      AsyncImage(url: URL(string: imageUrl)) { image in
        image
          .resizable()
          .clipShape(RoundedRectangle(cornerRadius: 4))
      } placeholder: {
        RoundedRectangle(cornerRadius: 4)
          .foregroundColor(.gray)
      }
      .aspectRatio(contentMode: .fit)
      .frame(width: 40, height: 40, alignment: .center)
      VStack(alignment: .leading) {
        Text("\(title)")
          .foregroundColor(.title)
          .font(.body.weight(.semibold))
        HStack {
          Text("\(price)")
            .foregroundColor(.subtitle)
          HStack(spacing: 0) {
            Text(priceChange > 0 ? "+" : "")
            Text("\(String(format: "%.2f", priceChange))%")
          }
          .foregroundColor(priceChange >= 0 ? .green : .red)
        }
        .font(.caption.weight(.medium))
      }
    }
  }
}

struct MarketItemSectionView: View {
  let title: String
  @Binding var isLoading: Bool
  @Binding var marketItems: [MarketDataInfo]
  
  let onTap: (MarketDataInfo) -> Void
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.headline)
        .foregroundColor(.title)
        .padding(.leading)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          if (isLoading) {
            ForEach(0...9, id: \.self) { item in
              MarketItemView(imageUrl: "", title: "something", price: "123", priceChange: 23.4)
            }
            .redacted(reason: .placeholder)
          } else {
            ForEach(marketItems) { item in
              Button(action: {
                onTap(item)
              }) {
                MarketItemView(
                  imageUrl: item.image,
                  title: item.name,
                  price: String(format: "%.2f ◎", item.floorPrice),
                  priceChange: Float(item.priceChange24hToken))
              }
            }
          }
        }
        .padding(.horizontal)
      }
    }
  }
}

struct MarketView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      MarketView()
    }
  }
}

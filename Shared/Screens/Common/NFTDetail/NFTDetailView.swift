//
//  NFTDetailView.swift
//  Bitsfi
//
//  Created by Oliver Le on 01/07/2022.
//

import Foundation
import SwiftUI
import SwiftUICharts

struct NFTDetailView: View {
  @Environment(\.openURL) var openURL
  @ObservedObject var vm: NFTDetailViewModel
  private var chartStyle: ChartStyle {
    let chartStyle = Styles.barChartStyleNeonBlueLight
    chartStyle.darkModeStyle = Styles.barChartStyleNeonBlueDark
    return chartStyle
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            VStack {
              Text("Supply")
                .font(.caption.weight(.medium))
                .foregroundColor(.subtitle)
              Text(vm.supply)
                .font(.body.weight(.semibold))
                .foregroundColor(.title)
            }
            
            VStack {
              Text("Mint Price")
                .font(.caption.weight(.medium))
                .foregroundColor(.subtitle)
              Text(vm.mintPrice)
                .font(.body.weight(.semibold))
                .foregroundColor(.title)
            }
            
            VStack {
              Text("Floor Price")
                .font(.caption.weight(.medium))
                .foregroundColor(.subtitle)
              Text(vm.floorPrice)
                .font(.body.weight(.semibold))
                .foregroundColor(.title)
            }
            
            VStack {
              Text("Average Price")
                .font(.caption.weight(.medium))
                .foregroundColor(.subtitle)
              Text(vm.averagePrice)
                .font(.body.weight(.semibold))
                .foregroundColor(.title)
            }
            
            VStack {
              Text("24h volume")
                .font(.caption.weight(.medium))
                .foregroundColor(.subtitle)
              Text(vm.vol24h)
                .font(.body.weight(.semibold))
                .foregroundColor(.title)
            }
            
            VStack {
              Text("Total list")
                .font(.caption.weight(.medium))
                .foregroundColor(.subtitle)
              Text(vm.totalList)
                .font(.body.weight(.semibold))
                .foregroundColor(.title)
            }
            
            VStack {
              Text("Market Cap")
                .font(.caption.weight(.medium))
                .foregroundColor(.subtitle)
              Text(vm.marketCap)
                .font(.body.weight(.semibold))
                .foregroundColor(.title)
            }
          }
        }
        
        if vm.isLoadingFloorPriceChartData {
          ProgressView()
            .frame(minWidth: 200, maxWidth: UIScreen.main.bounds.width - 16, minHeight: 300)
        } else {
          LineView(data: vm.floorPriceChartData, style: chartStyle)
            .frame(minWidth: 200, maxWidth: UIScreen.main.bounds.width - 16, minHeight: 300)
        }
        
        Button(action: {
          if let url = vm.ctaURL {
            openURL(url)
          }
        }) {
          Text(vm.ctaTitle)
            .fontWeight(.semibold)
        }
        .buttonStyle(.primaryExpanded)
        .shadow(radius: 4)
        .padding(.top)
        
        Text("Statistics")
          .font(.headline)
          .foregroundColor(.title)
          .padding(.top)
        
        VStack {
          HStack {
            if (vm.isLoadingSaleVolChartData) {
              ProgressView()
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 300)
            } else {
              BarChartView(
                data: ChartData(values: vm.saleVolChartData),
                title: "Sales Volume",
                legend: "",
                style: chartStyle,
                cornerImage: nil
              )
            }
            
            if (vm.isLoadingAveragePriceData) {
              ProgressView()
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 300)
            } else {
              BarChartView(
                data: ChartData(values: vm.averagePriceChartData),
                title: "Average Price",
                legend: "",
                style: chartStyle,
                cornerImage: nil
              )
            }
          }
          
          HStack {
            if (vm.isLoadingHoldDurationChartData) {
              ProgressView()
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 300)
            } else {
              BarChartView(
                data: ChartData(values: vm.holdDurationChartData),
                title: "Hold duration",
                legend: "",
                style: chartStyle,
                cornerImage: nil
              )
            }
            
            if (vm.isLoadingTopHolderChartData) {
              ProgressView()
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 300)
            } else {
              BarChartView(
                data: ChartData(values: vm.topHolderChartData),
                title: "Whales (Top Holders)",
                legend: "",
                style: chartStyle,
                cornerImage: nil
              )
            }
          }
        }
      }
      .padding()
    }
    .navigationBarTitle(vm.name, displayMode: .inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        HStack {
          MarketItemView(
            imageUrl: vm.image,
            title: vm.name,
            price: vm.floorPrice,
            priceChange: Float(vm.floorPriceChangeValue)
          )
          Spacer()
        }
      }
    }
    .task {
      vm.viewDidAppear()
    }
  }
}

struct NFTDetailView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      NFTDetailView(vm: NFTDetailViewModel(
        nftService: NFTServiceImpl(),
        item: .mock)
      )
    }
  }
}


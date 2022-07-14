//
//  DataTableView.swift
//  Bitsfi
//
//  Created by Oliver Le on 17/06/2022.
//

import SwiftUI

struct DataTableView: View {
  enum OrderType: String, Equatable {
    case asc, desc
  }
  
  enum OrderBy: String, Equatable {
    case name, vol, lastPrice, changeIn24h
  }
  
  @Binding var marketData: [MarketDataInfo]
  @Binding var isLoading: Bool
  let onTap: (MarketDataInfo) -> Void
  
  @State private var orderBy: OrderBy = .vol
  @State private var orderType: OrderType = .desc
  @State private var showPopover: Bool = false
  @State private var timer: Timer? = nil
  
  var body: some View {
    VStack(spacing: 4) {
      HStack {
        HStack(spacing: 4) {
          Button(action: {
            if orderBy == .name {
              orderType = orderType == .asc ? .desc : .asc
              return
            }
            orderBy = .name
            orderType = .asc
          }) {
            HStack(spacing: 2) {
              Text("Name")
                .foregroundColor(orderBy == .name ? .title : .subtitle)
                .font(.caption)
              Image(getImageName(by: .name))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
            }
          }
          Text("/")
            .foregroundColor(.subtitle)
            .font(.caption)
          Button(action: {
            if orderBy == .vol {
              orderType = orderType == .asc ? .desc : .asc
              return
            }
            orderBy = .vol
            orderType = .asc
          }) {
            HStack(spacing: 2) {
              Text("Vol")
                .foregroundColor(orderBy == .vol ? .title : .subtitle)
                .font(.caption)
              Image(getImageName(by: .vol))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
            }
          }
        }
        Spacer()
        Button(action: {
          if orderBy == .lastPrice {
            orderType = orderType == .asc ? .desc : .asc
            return
          }
          orderBy = .lastPrice
          orderType = .asc
        }) {
          HStack(spacing: 2) {
            Text("Last Price")
              .foregroundColor(orderBy == .lastPrice ? .title : .subtitle)
              .font(.caption)
            Image(getImageName(by: .lastPrice))
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 12, height: 12)
          }
        }
        Button(action: {
          if orderBy == .changeIn24h {
            orderType = orderType == .asc ? .desc : .asc
            return
          }
          orderBy = .changeIn24h
          orderType = .asc
        }) {
          HStack(spacing: 2) {
            Text("24h Change")
              .foregroundColor(orderBy == .changeIn24h ? .title : .subtitle)
              .font(.caption)
            Image(getImageName(by: .changeIn24h))
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 12, height: 12)
          }
        }
      }
      .padding(.horizontal)
      .padding(.bottom, 2)
      ScrollView(showsIndicators: true) {
        LazyVStack {
          if (isLoading) {
            ForEach(0...9, id: \.self) { item in
              DataTableRowView(
                image: "",
                name: "Collection Name",
                vol24h: "Vol 123,456.23",
                floorPrice: "123 ",
                floorPriceChange24h: "+12.34%",
                isUp: true)
              .redacted(reason: .placeholder)
            }
            .padding(.bottom, 8)
          } else {
            ForEach(marketData) { item in
              Button(action: {
                onTap(item)
              }) {
                DataTableRowView(
                  image: item.image,
                  name: item.name,
                  vol24h: String(format: "Vol %.2f  ◎", item.volume24h),
                  floorPrice: String(format: "%.2f  ◎", item.floorPrice),
                  floorPriceChange24h: "\(item.floorPriceChange24h > 0 ? "+" : "")\(String(format: "%.2f", item.floorPriceChange24h))%",
                  isUp: item.floorPriceChange24h > 0)
              }
              .padding(.bottom, 8)
            }
          }
        }
        .padding(.horizontal)
      }
    }
    .onChange(of: orderBy) { orderBy in
      refresh()
    }
    .onChange(of: orderType) { orderType in
      refresh()
    }
  }
  
  private func refresh() {
    marketData = marketData.sorted(by: { lhs, rhs in
      switch (orderBy, orderType) {
      case (.name, .desc):
        return lhs.name > rhs.name
      case (.name, .asc):
        return lhs.name < rhs.name
      case (.vol, .desc):
        return lhs.volume24h > rhs.volume24h
      case (.vol, .asc):
        return lhs.volume24h < rhs.volume24h
      case (.lastPrice, .desc):
        return lhs.floorPrice > rhs.floorPrice
      case (.lastPrice, .asc):
        return lhs.floorPrice < rhs.floorPrice
      case (.changeIn24h, .desc):
        return lhs.floorPriceChange24h > rhs.floorPriceChange24h
      case (.changeIn24h, .asc):
        return lhs.floorPriceChange24h < rhs.floorPriceChange24h
      }
    })
  }
  
  private func getImageName(by: OrderBy) -> String {
    guard by == orderBy else {
      return "ico_order_unselect"
    }
    switch orderType {
    case .asc:
      return "ico_order_asc"
    case .desc:
      return "ico_order_desc"
    }
  }
}

struct DataTableView_Previews: PreviewProvider {
  
  static var previews: some View {
    DataTableView(marketData: .constant([]), isLoading: .constant(false), onTap: { _ in })
      .previewLayout(.sizeThatFits)
  }
}


struct DataTableRowView: View {
  let image: String
  let name: String
  let vol24h: String
  let floorPrice: String
  let floorPriceChange24h: String
  let isUp: Bool
  
  var body: some View {
    HStack {
      HStack {
        AsyncImage(url: URL(string: image)) { image in
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
          Text(name)
            .font(.body.weight(.semibold))
            .foregroundColor(.title)
            .lineLimit(1)
          
          Text(vol24h)
            .font(.caption.weight(.medium))
            .foregroundColor(.subtitle)
        }
      }
      Spacer()
      HStack(spacing: 4) {
        VStack(alignment: .trailing) {
          Text(floorPrice)
            .bold()
            .foregroundColor(.title)
        }
        Text("")
      }
      Text(floorPriceChange24h)
        .font(.subheadline.weight(.semibold))
        .padding(.vertical, 8)
        .foregroundColor(.white)
        .frame(width: 80)
        .background(isUp ? Color.green : Color.red)
        .cornerRadius(4)
    }
  }
}

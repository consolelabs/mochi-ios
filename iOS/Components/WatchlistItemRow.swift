//
//  WatchlistItemRow.swift
//  Mochi
//
//  Created by Oliver Le on 29/01/2023.
//

import ComposableArchitecture
import SwiftUI

extension WatchlistItem.State {
  static var mockIncrease: Self {
    let sparklineData = SparklineData(price: [22939.06268266951,
                                              22905.933838447523,
                                              22905.650386560363,
                                              22872.269439060954,
                                              22892.74230691543,
                                              22828.063535702233,
                                              22846.403473678234,
                                              22928.759108503713,
                                              23030.598701476505,
                                              22838.60376102746,
                                              22819.5453267843,
                                              22922.03677408276,
                                              22851.48649766225,
                                              22846.464932342882,
                                              22539.169943166435,
                                              22552.164997205764,
                                              22728.727315719676,
                                              22736.66142892971,
                                              22771.537293805894,
                                              22748.428856569706,
                                              22741.18270141108,
                                              22681.315446037137,
                                              22766.08655276583,
                                              22736.102518578056,
                                              22784.727629274923,
                                              22707.395636945126,
                                              22733.141386037303,
                                              22794.08003043052,
                                              22938.642903279277,
                                              22851.463206859717,
                                              22945.215282098827,
                                              22819.03379003602,
                                              22882.031036519216,
                                              22881.59327125767,
                                              22891.494888575995,
                                              22970.847176497045,
                                              23066.963597958547,
                                              22725.853463959884,
                                              23014.032948297532,
                                              22988.738256940604,
                                              22921.683182415767,
                                              22984.87497643721,
                                              22983.25895237566,
                                              23101.247651261518,
                                              23097.160591408596,
                                              23116.062970479277,
                                              23078.974242037108,
                                              23137.6685846802,
                                              23121.077890602133,
                                              23068.20851471796,
                                              23054.641168848542,
                                              22908.34385765688,
                                              22932.43798130407,
                                              22927.604867412418,
                                              22987.30104062341,
                                              22847.07615123169,
                                              22853.6099011747,
                                              22947.895084793614,
                                              22848.733165629736,
                                              22903.912623203036,
                                              23021.872378490665,
                                              23017.90581898765,
                                              23003.027613376256,
                                              22984.268717113315,
                                              22819.824254865693,
                                              22630.02981007774,
                                              22686.93596273721,
                                              22503.604291520667,
                                              22592.740737335873,
                                              22645.38424155199,
                                              22638.252549783883,
                                              22689.92692886473,
                                              22725.05941576793,
                                              22730.366293932922,
                                              22680.71137061266,
                                              22627.163681813323,
                                              22647.726190690937,
                                              22607.673803663445,
                                              22702.818538631516,
                                              22604.608365553144,
                                              22437.676766780296,
                                              22554.235235968128,
                                              22655.241458162487,
                                              22581.523269433706,
                                              22702.12418805827,
                                              22761.833451751678,
                                              22898.7980374854,
                                              23399.023332793633,
                                              22888.68250881053,
                                              23073.579085541896,
                                              23179.670864114636,
                                              23199.74831839161,
                                              23193.105707756087,
                                              23144.150349354662,
                                              23194.32096022547,
                                              23194.32096022547,
                                              23155.50104787323,
                                              23075.613597377687,
                                              22994.85865045693,
                                              23033.457728533405,
                                              22983.56056757172,
                                              22950.860621237636,
                                              22987.67891168428,
                                              23126.374756855916,
                                              23085.394505542157,
                                              23083.196456779537,
                                              23025.90735060153,
                                              22991.85109305622,
                                              23007.26951139599,
                                              23048.701384222306,
                                              23077.024634415382,
                                              23138.53095691874,
                                              23084.329782044697,
                                              23015.901548681453,
                                              23037.80289259157,
                                              22912.110179854437,
                                              22651.832045594743,
                                              22794.97090041975,
                                              22804.0814137677,
                                              22819.369722044754,
                                              22938.888193893352,
                                              23005.650858585905,
                                              23063.246847574475,
                                              22977.523727303702,
                                              22928.52922218007,
                                              22969.125186965503,
                                              22950.564857167803,
                                              22919.896394038755,
                                              22858.2754129072,
                                              23065.72503074158,
                                              22981.74851724552,
                                              23139.442062004015,
                                              23284.28121653886,
                                              23205.749283946065,
                                              23232.40080945729,
                                              23133.223981834642,
                                              23108.67152637529,
                                              23032.513357294472,
                                              23084.50814774056,
                                              23147.84429509763,
                                              23098.35844622353,
                                              23101.62528671022,
                                              23147.374204147327,
                                              23092.6576700184,
                                              23087.676847364877,
                                              23057.85805357843,
                                              22992.996030864422,
                                              23028.131671652012,
                                              23013.02960424233,
                                              22992.0968668102,
                                              22992.663198053742,
                                              22990.32692105584,
                                              22986.525072122662,
                                              22954.37210391239,
                                              23039.81642883673,
                                              23038.595650864423,
                                              23048.001140019627,
                                              23015.997448179136,
                                              23051.313020196194,
                                              23004.681115666193,
                                              23017.957098506406,
                                              23002.99400172966,
                                              23008.07879887463,
                                              23125.088660679452,
                                              23253.831937559182,
                                              23126.43176859156,
                                              23234.964783472773,
                                              23232.23438663692,
                                              23272.643669710767])
    return Self(id: UUID().uuidString,
                name: "Bitcoin",
                symbol: "BTC",
                currentPrice: 23444.245,
                image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
                sparklineIn7D: sparklineData,
                priceChangePercentage24h: 1.9187,
                priceChangePercentage7d: 2.9537)
  }
  
  static var mockDecrease: Self {
    let sparklineData = SparklineData(price: [22939.06268266951,
                                              22905.933838447523,
                                              22905.650386560363,
                                              22872.269439060954,
                                              22892.74230691543,
                                              22828.063535702233,
                                              22846.403473678234,
                                              22928.759108503713,
                                              23030.598701476505,
                                              22838.60376102746,
                                              22819.5453267843,
                                              22922.03677408276,
                                              22851.48649766225,
                                              22846.464932342882,
                                              22539.169943166435,
                                              22552.164997205764,
                                              22728.727315719676,
                                              22736.66142892971,
                                              22771.537293805894,
                                              22748.428856569706,
                                              22741.18270141108,
                                              22681.315446037137,
                                              22766.08655276583,
                                              22736.102518578056,
                                              22784.727629274923,
                                              22707.395636945126,
                                              22733.141386037303,
                                              22794.08003043052,
                                              22938.642903279277,
                                              22851.463206859717,
                                              22945.215282098827,
                                              22819.03379003602,
                                              22882.031036519216,
                                              22881.59327125767,
                                              22891.494888575995,
                                              22970.847176497045,
                                              23066.963597958547,
                                              22725.853463959884,
                                              23014.032948297532,
                                              22988.738256940604,
                                              22921.683182415767,
                                              22984.87497643721,
                                              22983.25895237566,
                                              23101.247651261518,
                                              23097.160591408596,
                                              23116.062970479277,
                                              23078.974242037108,
                                              23137.6685846802,
                                              23121.077890602133,
                                              23068.20851471796,
                                              23054.641168848542,
                                              22908.34385765688,
                                              22932.43798130407,
                                              22927.604867412418,
                                              22987.30104062341,
                                              22847.07615123169,
                                              22853.6099011747,
                                              22947.895084793614,
                                              22848.733165629736,
                                              22903.912623203036,
                                              23021.872378490665,
                                              23017.90581898765,
                                              23003.027613376256,
                                              22984.268717113315,
                                              22819.824254865693,
                                              22630.02981007774,
                                              22686.93596273721,
                                              22503.604291520667,
                                              22592.740737335873,
                                              22645.38424155199,
                                              22638.252549783883,
                                              22689.92692886473,
                                              22725.05941576793,
                                              22730.366293932922,
                                              22680.71137061266,
                                              22627.163681813323,
                                              22647.726190690937,
                                              22607.673803663445,
                                              22702.818538631516,
                                              22604.608365553144,
                                              22437.676766780296,
                                              22554.235235968128,
                                              22655.241458162487,
                                              22581.523269433706,
                                              22702.12418805827,
                                              22761.833451751678,
                                              22898.7980374854,
                                              23399.023332793633,
                                              22888.68250881053,
                                              23073.579085541896,
                                              23179.670864114636,
                                              23199.74831839161,
                                              23193.105707756087,
                                              23144.150349354662,
                                              23194.32096022547,
                                              23194.32096022547,
                                              23155.50104787323,
                                              23075.613597377687,
                                              22994.85865045693,
                                              23033.457728533405,
                                              22983.56056757172,
                                              22950.860621237636,
                                              22987.67891168428,
                                              23126.374756855916,
                                              23085.394505542157,
                                              23083.196456779537,
                                              23025.90735060153,
                                              22991.85109305622,
                                              23007.26951139599,
                                              23048.701384222306,
                                              23077.024634415382,
                                              23138.53095691874,
                                              23084.329782044697,
                                              23015.901548681453,
                                              23037.80289259157,
                                              22912.110179854437,
                                              22651.832045594743,
                                              22794.97090041975,
                                              22804.0814137677,
                                              22819.369722044754,
                                              22938.888193893352,
                                              23005.650858585905,
                                              23063.246847574475,
                                              22977.523727303702,
                                              22928.52922218007,
                                              22969.125186965503,
                                              22950.564857167803,
                                              22919.896394038755,
                                              22858.2754129072,
                                              23065.72503074158,
                                              22981.74851724552,
                                              23139.442062004015,
                                              23284.28121653886,
                                              23205.749283946065,
                                              23232.40080945729,
                                              23133.223981834642,
                                              23108.67152637529,
                                              23032.513357294472,
                                              23084.50814774056,
                                              23147.84429509763,
                                              23098.35844622353,
                                              23101.62528671022,
                                              23147.374204147327,
                                              23092.6576700184,
                                              23087.676847364877,
                                              23057.85805357843,
                                              22992.996030864422,
                                              23028.131671652012,
                                              23013.02960424233,
                                              22992.0968668102,
                                              22992.663198053742,
                                              22990.32692105584,
                                              22986.525072122662,
                                              22954.37210391239,
                                              23039.81642883673,
                                              23038.595650864423,
                                              23048.001140019627,
                                              23015.997448179136,
                                              23051.313020196194,
                                              23004.681115666193,
                                              23017.957098506406,
                                              23002.99400172966,
                                              23008.07879887463,
                                              23125.088660679452,
                                              23253.831937559182,
                                              23126.43176859156,
                                              23234.964783472773,
                                              23232.23438663692,
                                              23272.643669710767])
    return Self(id: UUID().uuidString,
                name: "Bitcoin",
                symbol: "BTC",
                currentPrice: 23444.245,
                image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
                sparklineIn7D: sparklineData,
                priceChangePercentage24h: -1.9187,
                priceChangePercentage7d: -2.9537)
  }
}


extension WatchlistItem.State {
  init(from vm: WatchlistViewModel.WatchlistPresenter) {
    self.id = vm.id
    self.name = vm.name
    self.symbol = vm.symbol
    self.currentPrice = vm.currentPriceValue
    self.image = vm.image
    self.sparklineIn7D = WatchlistItem.State.SparklineData(price: vm.sparklineIn7d.price)
    self.priceChangePercentage24h = vm.priceChangePercentage24hValue
    self.priceChangePercentage7d = vm.priceChangePercentage7dValue
  }
}

struct WatchlistItem: ReducerProtocol {
  struct State: Equatable, Identifiable {
    struct SparklineData: Equatable {
      let price: [Double]
    }
    let id: String
    let name: String
    let symbol: String
    let currentPrice: Double
    let image: String
    let sparklineIn7D: SparklineData
    let priceChangePercentage24h: Double
    let priceChangePercentage7d: Double
  }
  
  
  enum Action: Equatable {
  }
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
  }
}

struct WatchlistItemRow: View {
  // MARK: - State
  let store: StoreOf<WatchlistItem>
  
  init(store: StoreOf<WatchlistItem>) {
    self.store = store
  }

  // MARK: - Body
  var body: some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 2) {
        // MARK: Name
        HStack(spacing: 8) {
          AsyncImage(url: URL(string: viewStore.state.image)) { phase in
            switch phase {
            case let .success(image):
              image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            case .empty, .failure:
              Circle()
                .foregroundColor(Theme.gray)
                .frame(width: 24, height: 24)
            @unknown default:
              EmptyView()
            }
          }
          Text(viewStore.state.symbol.uppercased())
            .lineLimit(1)
            .foregroundColor(Theme.text1)
            .font(.inter(size: 15, weight: .bold))
        }
        .frame(width: 90, alignment: .leading)
        // MARK: Value
        HStack(spacing: 6) {
          (
            Text("$")
              .foregroundColor(Theme.text4)
            +
            Text(viewStore.state.currentPrice.toPriceFormat() ?? "NA")
              .foregroundColor(Theme.text1)
          )
          .lineLimit(1)
          .minimumScaleFactor(0.5)
          .font(.interSemiBold(size: 15))
          
          HStack(spacing: 0) {
            if viewStore.state.priceChangePercentage7d >= 0 {
              Asset.increase
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 13, height: 13)
            } else {
              Asset.decrease
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 13, height: 13)
              
            }
            Text(String(format: "%.2f", viewStore.state.priceChangePercentage7d)+"%")
              .font(.interSemiBold(size: 11))
              .foregroundColor(
                viewStore.state.priceChangePercentage7d > 0
                ? Color(red: 0.13, green: 0.75, blue: 0.58)
                : Color(red: 0.99, green: 0.37, blue: 0.35)
              )
          }
        }
        Spacer()
        // MARK: Sparkline
        SparklineView(
          prices: viewStore.state.sparklineIn7D.price,
          color: viewStore.state.priceChangePercentage7d >= 0 ? Theme.green2 : Theme.red
        )
        .frame(width: 70, height: 24)
      }
      .padding(.vertical, 16)
      .padding(.horizontal, 20)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .circular)
          .foregroundColor(.white)
      )
    }
  }
}

struct WatchlistItemRow_Previews: PreviewProvider {
  static var previews: some View {
    WatchlistItemRow(
      store: Store(
        initialState: .mockIncrease,
        reducer: WatchlistItem()
      )
    )
    .padding()
    .background(Theme.text2)
    .previewLayout(.sizeThatFits)
    .previewDisplayName("Increase")
    
    WatchlistItemRow(
      store: Store(
        initialState: .mockDecrease,
        reducer: WatchlistItem()
      )
    )
    .padding()
    .background(Theme.text2)
    .previewLayout(.sizeThatFits)
    .previewDisplayName("Decrease")
  }
}

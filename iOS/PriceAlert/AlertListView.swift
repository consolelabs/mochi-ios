//
//  AlertListView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 11/11/2022.
//

import SwiftUI

struct AlertListView: View {
  @ObservedObject var vm: AlertListViewModel
  @State private var showSetPriceSheet: Bool = false
  
  var body: some View {
    NavigationView {
      List {
        ForEach(vm.data, id: \.id) { item in
          ZStack(alignment: .center) {
            AlertCardView(alert: item)
            NavigationLink(
              destination: EditPriceAlertView(
                vm: EditPriceAlertViewModel(
                  alertService: PriceAlertServiceImpl(),
                  priceAlert: EditPriceAlertParam(id: item.id,
                                                  tokenId: item.tokenId,
                                                  tokenName: item.tokenName,
                                                  tokenSymbol: item.symbol,
                                                  price: item.priceValue,
                                                  isEnable: item.isEnable,
                                                  trend: item.trendValue)
                ),
                shouldUpdate: {
                  vm.fetchAlertList(shouldShowLoading: false)
                }
              )
            ) {
              EmptyView()
            }
            .opacity(0)
          }
          .swipeActions(allowsFullSwipe: false) {
            Button {
              vm.toggleAlert(id: item.id)
            } label: {
              Label(item.isEnable ? "Mute" : "Unmute", systemImage: item.isEnable ? "bell.slash.fill" : "bell.fill")
            }
            .tint(.gray)
            
            Button(role: .destructive) {
              vm.deleteAlert(id: item.id)
            } label: {
              Label("Delete", systemImage: "trash.fill")
            }
          }
        }
        .listSectionSeparator(.hidden)

      }
      .listStyle(.plain)
      .navigationTitle("Price Alert")
      .overlay {
        if vm.isLoading {
          ActivityIndicator()
            .frame(width: 40, height: 40)
            .foregroundColor(.appPrimary)
        }
      }
      .background {
        if vm.data.isEmpty {
          Text("There is no alert. Tap the + button above to create one!")
            .multilineTextAlignment(.center)
            .foregroundColor(.subtitle)
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { showSetPriceSheet.toggle() }) {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showSetPriceSheet) {
        SelectTokenView(vm: WatchlistViewModel(defiService: DefiServiceImpl()))
      }
    }
    .navigationViewStyle(.stack)
    .task {
      vm.requestNotificationAuth()
    }
    .onChange(of: showSetPriceSheet, perform: { isShowing in
      if !isShowing {
        vm.fetchAlertList(shouldShowLoading: true)
      }
    })
  }
}

struct AlertListView_Previews: PreviewProvider {
  static var previews: some View {
    AlertListView(vm: AlertListViewModel(alertService: PriceAlertServiceImpl()))
  }
}


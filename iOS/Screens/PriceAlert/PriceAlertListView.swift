//
//  PriceAlertListView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 03/04/2023.
//

import SwiftUI


struct PriceAlertListView: View {
  @ObservedObject var vm: PriceAlertListViewModel
  
  var body: some View {
    ZStack {
      Theme.gray
        .ignoresSafeArea()
      ScrollView {
        if vm.isLoading {
          ForEach(0..<5, id: \.self) { id in
            sectionView(section: .mock)
          }
          .redacted(reason: .placeholder)
        } else {
          ForEach(vm.sections, id: \.id) {
            sectionView(section: $0)
          }
        }
      }
    }
    .refreshable {
      Task(priority: .high) {
        await vm.fetchList()
      }
    }
    .navigationTitle("Price Alerts")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Price Alerts")
          .font(.inter(size: 16, weight: .bold))
          .foregroundColor(Theme.text1)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { vm.showNewAlert = true }) {
          Label("Add new alert", systemImage: "plus.circle.fill")
        }
      }
    }
    .fullScreenCover(isPresented: $vm.showNewAlert) {
      AlertSelectTokenView { isSuccess in
        if isSuccess {
          Task(priority: .high) {
            await vm.fetchList()
          }
        }
      }
    }
  }
  
  private func sectionView(section: PriceAlertSection) -> some View {
    VStack(spacing: 8) {
      TokenPriceHeaderView(
        data: TokenPriceHeaderData(
          id: section.id,
          tokenPair: section.tokenPair,
          pricingData: section.pricingData
        )
      )
      .padding(.top, 16)
      ForEach(section.rows) { row in
        HStack(spacing: 8) {
          Image(row.icon)
            .resizable()
            .frame(width: 20, height: 20)
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
          Text(row.title)
            .font(.inter(size: 15, weight: .bold))
            .foregroundColor(Theme.text1)
          
          Spacer()
          
          Text(row.description)
            .font(.inter(size: 11, weight: .bold))
            .foregroundColor(.white)
            .frame(height: 18)
            .padding(.horizontal, 6)
            .background(Color(red: 0.294, green: 0.333, blue: 0.388, opacity: 0.5))
            .cornerRadius(8)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          Button(role: .destructive, action: { vm.deleteItem(sectionId: section.id, item: row) } ) {
            Label("Delete", systemImage: "trash")
          }
        }
      }
    }
    .padding(.horizontal, 16)
  }
}

struct PriceAlertListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      PriceAlertListView(
        vm: PriceAlertListViewModel(
          mochiService: MochiServiceImpl()
        )
      )
    }
  }
}

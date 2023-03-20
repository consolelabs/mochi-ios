//
//  SetPriceAlertView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 12/11/2022.
//

import SwiftUI

struct SetPriceAlertView: View {
  @ObservedObject var vm: SetPriceAlertViewModel
  
  @State private var offset = CGFloat.zero
  @Binding var shouldDismiss: Bool
  
  var body: some View {
    VStack {
      Text("Notify when price is")
        .font(.system(.title, design: .rounded).weight(.semibold))
        .padding(.top)
      
      Picker("Direction", selection: $vm.priceTrend) {
        Text("Below")
          .tag(PriceTrend.down)
        
        Text("Above")
          .tag(PriceTrend.up)
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding(.horizontal)
      
      Text("$\(vm.currentPrice.formatted())")
        .font(.system(.largeTitle, design: .rounded).weight(.bold))
        .foregroundColor(vm.priceTrend == .up ? .green : .red)
        .padding(.vertical)
      
      ZStack {
        RoundedRectangle(cornerRadius: 2)
          .frame(width: 3, height: 200)
        ScrollViewReader { proxy in
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 16) {
              ForEach(Array(vm.prices.enumerated()), id: \.offset) { (index, item) in
                GeometryReader { reader in
                  RoundedRectangle(cornerRadius: 2)
                    .frame(width: 3, height: 100, alignment: .center)
                    .scaleEffect(y: getTickHeight(index: index))
                    .opacity(reader.frame(in: .global).midX >= UIScreen.main.bounds.width / 2 ? 0.2 : 1)
                    .frame(height: 140, alignment: .center)
                    .overlay(alignment: .top) {
                      if (index+1) % 10 == 1 {
                        Text("$\(item.formatted())")
                          .lineLimit(1)
                          .frame(minWidth: 80)
                          .font(.caption)
                          .offset(y: -1)
                          .opacity(reader.frame(in: .global).midX >= UIScreen.main.bounds.width / 2 ? 0.2 : 1)
                      }
                    }
                }
                .frame(width: 3, height: 150)
                .id(index)
              }
            }
            .background(GeometryReader {
              Color.clear.preference(key: ViewOffsetKey.self,
                                     value: -$0.frame(in: .named("scroll")).origin.x)
            })
            .onPreferenceChange(ViewOffsetKey.self) { offset in
              let itemWidth = 3
              let spacing = 16
              let totalPriceItem = vm.prices.count
              let scrollViewWidth = CGFloat((totalPriceItem * itemWidth) + ((totalPriceItem - 1) * spacing))
              let distanceFromFirstElementToHalfScreen = offset + (UIScreen.main.bounds.width / 2) /*- CGFloat(52)*/
              var index = Int(distanceFromFirstElementToHalfScreen / scrollViewWidth * CGFloat(totalPriceItem))
              if index < 0 { index = 0 }
              if index >= totalPriceItem { index = totalPriceItem - 1 }
              vm.currentPrice = vm.prices[index]
              if (Int(offset) % (itemWidth + spacing)) == 0 {
                Haptics.shared.notify(.success)
              }
            }
          }
          .coordinateSpace(name: "scroll")
          .onAppear {
            proxy.scrollTo(110)
          }
        }
      }
      
      Spacer()
      
    }
    .safeAreaInset(edge: .bottom, content: {
      Button(action: { vm.setPriceAlert() }) {
        Text("Confirm")
          .font(.system(.callout, design: .rounded).weight(.semibold))
          .foregroundColor(.white)
          .frame(height: 50)
          .frame(maxWidth: .infinity)
          .background(Color.appPrimary)
          .cornerRadius(10)
          .padding()
      }
      .buttonStyle(PlainButtonStyle())
    })
    .alert("Error", isPresented: $vm.showError, actions: {
      Button(action: {}) {
        Text("OK")
      }
    }, message: {
      Text(vm.errorMessage)
    })
    .onChange(of: vm.shouldDismiss) { shouldDismiss in
      if shouldDismiss {
        self.shouldDismiss = shouldDismiss
      }
    }
    .overlay {
      if vm.isLoading {
        ActivityIndicator()
          .frame(width: 40, height: 40)
          .foregroundColor(.appPrimary)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        VStack {
          Text(vm.tokenName)
            .font(.system(.title3, design: .rounded).bold())
          Text(vm.tokenSymbol)
            .font(.footnote)
        }
      }
    }
  }
  
  func getTickHeight(index: Int) -> Double {
    switch (index + 1) % 10 {
    case 1: return 1
    case 6: return 0.5
    default: return 0.3
    }
  }
}

struct TokenPrice {
  let price: Double
}


struct SetPriceAlertView_Previews: PreviewProvider {
  static var previews: some View {
    SetPriceAlertView(
      vm: SetPriceAlertViewModel(
        alertService: PriceAlertServiceImpl(),
        tokenId: "",
        tokenName: "",
        tokenSymbol: "",
        price: 0
      ),
    shouldDismiss: .constant(false))
  }
}


extension View {
  func print(_ value: Any) -> Self {
    Swift.print(value)
    return self
  }
}

import UIKit

class Haptics {
    static let shared = Haptics()
    
    private init() { }

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}


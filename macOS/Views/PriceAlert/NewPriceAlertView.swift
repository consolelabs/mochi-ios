//
//  NewPriceAlertView.swift
//  Mochi Wallet (macOS)
//
//  Created by Oliver Le on 14/12/2022.
//

import SwiftUI

struct NewPriceAlertView: View {
  @ObservedObject var vm: SetPriceAlertViewModel
  @Binding var shouldDismiss: Bool

  @State private var step: Double = 0
  
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
      .labelsHidden()
      .padding(.horizontal)
      
      Text("$\(vm.currentPrice.formatted())")
        .font(.system(.largeTitle, design: .rounded).weight(.bold))
        .foregroundColor(vm.priceTrend == .up ? .green : .red)
        .padding(.vertical)
   
      Spacer()
      
      HStack {
        Text("-100%")
        Slider(value: $step, in: -100...100)
        Text("+100%")
      }
      .padding()
      
      Spacer()
    }
    .onChange(of: step, perform: vm.updateCurrentPriceFromInitPrice)
    .safeAreaInset(edge: .bottom, content: {
      Button(action: { vm.setPriceAlert() }) {
        Text("Confirm")
          .font(.system(.callout, design: .rounded).weight(.semibold))
          .foregroundColor(.white)
          .frame(height: 44)
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
    .navigationTitle(vm.tokenName)
  }
}

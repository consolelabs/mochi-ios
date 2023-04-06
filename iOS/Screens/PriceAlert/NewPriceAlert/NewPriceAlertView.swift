//
//  NewPriceAlertView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 05/04/2023.
//

import SwiftUI
import OSLog

extension AlertType {
  var label: String {
    switch self {
    case .priceReaches: return "Price reaches"
    case .priceRisesAbove: return "Price rises above"
    case .priceDropsTo: return "Price drops to"
    case .changeIsOver: return "Change is over"
    case .changeIsUnder: return "Change is under"
    }
  }
}

extension AlertFrequency {
  var label: String {
    switch self {
    case .onlyOnce: return "Only Once"
    case .onceADay: return "Once a day"
    case .always: return "Always"
    }
  }
}

struct NewPriceAlertView: View {
  enum Field: Hashable {
    case value
  }
  
  let data: TokenPriceHeaderData
  let didFinish: (Bool) -> Void
 
  @AppStorage("discordId", store: UserDefaults(suiteName: "group.so.console.mochi"))
  var discordId: String = ""

  @FocusState private var focus: Field?
  
  @State private var isLoading: Bool = false
  @State private var alertValue: String = ""
  @State private var alertType: AlertType = .changeIsOver
  @State private var frequency: AlertFrequency = .onlyOnce
  @State private var showSelectFrequency = false
  @State private var error: String = ""
  
  private var prefix: String {
    switch alertType {
    case .priceReaches, .priceRisesAbove, .priceDropsTo:
      return "$"
    case .changeIsOver, .changeIsUnder:
      return ""
    }
  }
  
  private var suffix: String {
    switch alertType {
    case .priceReaches, .priceRisesAbove, .priceDropsTo:
      return ""
    case .changeIsOver, .changeIsUnder:
      return "%"
    }
  }
  
  private var shouldDisableSubmit: Bool {
    return alertValue.isEmpty
  }
   
  @State private var mochiService = MochiServiceImpl()
  @State private var logger = Logger(subsystem: "so.console.mochi", category: "NewPriceAlertView")

  init(data: TokenPriceHeaderData, didFinish: @escaping (Bool) -> Void) {
    self.data = data
    self.didFinish = didFinish
  }
  
  var body: some View {
    ZStack {
      Theme.gray
        .ignoresSafeArea()
      ScrollView {
        VStack(spacing: 8) {
          // Header
          TokenPriceHeaderView(data: data)
            .padding(.top, 16)
          
          // Alert type
          Button(action: {
            toggleShowSelectFrequency()
          }) {
            HStack {
              Text(alertType.label)
                .font(.inter(size: 15, weight: .bold))
                .foregroundColor(Theme.text1)
              Spacer()
              Image(systemName: "chevron.right")
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundColor(Theme.text4)
                .frame(width: 24, height: 24)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
          }
            
          Spacer(minLength: 40)
          
          // Input value
          VStack {
            Text("Enter Value")
              .font(.inter(size: 16, weight: .bold))
              .foregroundColor(Theme.text3)
            HStack(spacing: 12) {
              Asset.icoChart
                .frame(width: 24, height: 24)
                .padding(10)
                .background(Color(red: 0.128, green: 0.75, blue: 0.58, opacity: 0.15))
                .clipShape(Circle())
              HStack(spacing: 2) {
                Text(prefix)
                  .font(.boldSora(size: 26))
                  .foregroundColor(Theme.text4)
                TextField("alert value", text: $alertValue, prompt: Text("0"))
                  .focused($focus, equals: .value)
                  .keyboardType(.numberPad)
                  .autocorrectionDisabled()
                  .textInputAutocapitalization(.never)
                  .font(.boldSora(size: 46))
                  .foregroundColor(Theme.text1)
                  .frame(maxWidth: 200)
                  .fixedSize()
                Text(suffix)
                  .font(.boldSora(size: 26))
                  .foregroundColor(Theme.text4)
              }
            }
          }
         
          Spacer()
          
        }
        .padding(.horizontal)
      }
    }
    .onTapGesture {
      focus = nil
    }
    .overlay(alignment: .bottom) {
      VStack(spacing: 16) {
        // frequency
        Picker("Frequency", selection: $frequency) {
          ForEach(AlertFrequency.allCases, id: \.self) { option in
            Text(option.label)
          }
        }
        .pickerStyle(.segmented)
        
        // Submit button
        Button(action: { handleSetAlert() }) {
          Text("Set Alert")
            .font(.interSemiBold(size: 18))
            .foregroundColor(shouldDisableSubmit ? Theme.text4 : Theme.text1)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.757, green: 0.769, blue: 0.78, opacity: 1))
            .cornerRadius(12)
        }
        .disabled(shouldDisableSubmit)
      }
      .padding(.horizontal)
      .padding(.bottom, 16)
    }
    .overlay {
      bottomSheet
    }
    .overlay {
      if isLoading {
        ActivityIndicator()
          .frame(width: 32, height: 32)
          .foregroundColor(.appPrimary)
      }
    }
    .navigationTitle("Add Alert")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Add Alert")
          .font(.inter(size: 16, weight: .bold))
          .foregroundColor(Theme.text1)
      }
    }
  }
  
  // MARK: - Bottom sheet
  private var bottomSheet: some View {
    // TODO: Find a way to dynamic this value?
    let offsetToHideBottomSheet: CGFloat = 500
    let paddingBottom: CGFloat = 30
    
    return ZStack(alignment: .bottom) {
      Color.black.opacity(showSelectFrequency ? 0.2 : 0)
        .onTapGesture {
          toggleShowSelectFrequency()
        }
      VStack(spacing: 16) {
        Text("Select alert type")
          .font(.inter(size: 16, weight: .bold))
          .foregroundColor(Theme.text3)
        
        VStack(alignment: .leading, spacing: 0) {
          ForEach(AlertType.allCases, id: \.self) { option in
            Button(action: {
              alertType = option
              toggleShowSelectFrequency()
            }) {
              HStack {
                Text(option.label)
                  .foregroundColor(Theme.text1)
                  .font(.interSemiBold(size: 18))
                Spacer()
                Image(systemName: option == alertType ? "checkmark.circle.fill" : "")
              }
              .padding(.vertical, 20)
            }
          }
        }
        .padding(.horizontal, 40)
      }
      .padding(.top, 20)
      .padding(.bottom, 20)
      .padding(.bottom, paddingBottom)
      .frame(maxWidth: .infinity)
      .background(Theme.gray)
      .cornerRadius(20, corners: [.topLeft, .topRight])
      .offset(y: showSelectFrequency ? paddingBottom : offsetToHideBottomSheet)
    }
    .ignoresSafeArea()
  }
  
  private func toggleShowSelectFrequency() {
    withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
      showSelectFrequency.toggle()
    }
  }
 
  @MainActor
  private func handleSetAlert() {
    isLoading = true
    
    let value = Double(alertValue) ?? 0
    
    Task(priority: .high) {
      let result = await mochiService.createPriceAlert(
        request: .init(
          alertType: alertType,
          frequency: frequency,
          priceByPercent: 0,
          symbol: data.tokenPair.left,
          userDiscordID: discordId,
          value: value
        )
      )
      switch result {
      case let .failure(error):
        logger.error("add new alert failed, error: \(error)")
      case .success:
        logger.info("add new alert success")
      }
      isLoading = false
      didFinish(true)
    }
  }
}

struct NewPriceAlertView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      NewPriceAlertView(data: .mock, didFinish: { _ in })
    }
  }
}

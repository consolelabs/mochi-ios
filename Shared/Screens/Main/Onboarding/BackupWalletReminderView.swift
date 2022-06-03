//
//  BackupWalletReminderView.swift
//  Bitsfi
//
//  Created by Oliver Le on 09/06/2022.
//

import SwiftUI

struct BackupWalletReminderView: View {
  @State private var lostSecretPhraseChecked: Bool = false
  @State private var shareSecretPhraseChecked: Bool = false
  @State private var keepSecretPhraseSecureChecked: Bool = false
  
  var body: some View {
    VStack {
      Text("Back up your wallet now!")
        .font(.title)
        .foregroundColor(.title)
      
      Text("In the next step you will see Secret Phrase \n (12 words) that allows you to recover a wallet")
        .foregroundColor(.subtitle)
        .multilineTextAlignment(.center)
      
      Spacer()
      
      RoundedRectangle(cornerRadius: 10)
        .frame(width: 130, height: 130)
        .foregroundColor(.appPrimary)
      
      Spacer()
      
      VStack(spacing: 16) {
        CheckBoxView(
          content: "If I lose my secret phrase, my funds will be lost forever.",
          isChecked: $lostSecretPhraseChecked)
        
        CheckBoxView(
          content: "If I expose or share my secret phrase to anybody, my funds can get stolen.",
          isChecked: $shareSecretPhraseChecked)
        
        CheckBoxView(
          content: "It is my full responsibility to keep my secret phrase secure.",
          isChecked: $keepSecretPhraseSecureChecked)
      }
      .padding()
      
      Spacer()
      
      NavigationLink {
        YourSecretPhraseView()
      } label: {
        Text("Continue")
          .bold()
          .padding()
          .frame(maxWidth: .infinity)
          .background(
            lostSecretPhraseChecked &&
            shareSecretPhraseChecked &&
            keepSecretPhraseSecureChecked ? Color.appPrimary : Color.gray)
          .foregroundColor(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .padding(.horizontal)
          .padding(.bottom)
      }
      .disabled(
        !lostSecretPhraseChecked ||
        !shareSecretPhraseChecked ||
        !keepSecretPhraseSecureChecked)
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct CheckBoxView: View {
  private let content: String
  @Binding private var isChecked: Bool
  
  init(content: String, isChecked: Binding<Bool>) {
    self.content = content
    self._isChecked = isChecked
  }
  
  var body: some View {
    Button(action: { isChecked.toggle() }) {
      HStack {
        Text(content)
          .font(.callout.weight(.medium))
          .fontWeight(.medium)
          .multilineTextAlignment(.leading)
          .foregroundColor(.title)
        
        Spacer()
        
        Image(systemName: isChecked ? "checkmark.circle" : "circle")
          .font(.body.weight(.bold))
          .foregroundColor(.title)
        
      }
      .padding()
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.title, lineWidth: 2)
      )
    }
  }
}

struct BackupWalletReminderView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NavigationView {
        BackupWalletReminderView()
      }
      NavigationView {
        BackupWalletReminderView()
      }
      .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
    }
  }
}


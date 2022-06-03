//
//  TermAgreementView.swift
//  Bitsfi
//
//  Created by Oliver Le on 09/06/2022.
//

import SwiftUI

struct TermAgreementView: View {
  @State private var termAccepted: Bool = false
  
  var body: some View {
    VStack {
      Form {
        Section {
          Link("Privacy Policy", destination: URL(string: "https://www.hackingwithswift.com/quick-start/swiftui")!)
          Link("Terms of Service", destination: URL(string: "https://www.hackingwithswift.com/quick-start/swiftui")!)
        } header: {
          Text("Please review the Bitsfi Terms of Service and Privacy Policy")
        }
      }
      
      Button(action: { termAccepted.toggle() }) {
        HStack {
          Image(systemName: termAccepted ? "checkmark.square" : "square")
            .font(.title3)
          Text("I've read and accept ther Terms of Service and Privacy Policy.")
            .multilineTextAlignment(.leading)
            .foregroundColor(Color.appPrimary)
        }
      }
      .padding()
     
      NavigationLink {
        BackupWalletReminderView()
      } label: {
        Text("Continue")
          .bold()
          .padding()
          .frame(maxWidth: .infinity)
          .background(termAccepted ? Color.appPrimary : Color.gray)
          .foregroundColor(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .padding(.horizontal)
          .padding(.bottom)
      }
      .disabled(!termAccepted)
    }
    .navigationTitle("Terms and Privacy Policy")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct TermAgreementView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      TermAgreementView()
    }
  }
}

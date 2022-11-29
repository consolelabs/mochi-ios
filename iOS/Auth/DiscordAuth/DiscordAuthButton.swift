//
//  DiscordAuthView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 21/11/2022.
//

import SwiftUI

struct DiscordAuthButton: View {
  let action: () -> Void
  
  var body: some View {
    Button(action: { action() }) {
      HStack {
        Image("discord")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 25, height: 25)
        
        Text("Continue with Discord")
          .font(.system(.body, design: .rounded).weight(.bold))
      }
      .padding()
      .foregroundColor(.white)
      .frame(maxWidth: .infinity, maxHeight: 50)
      .background(Color(red: 0.35, green: 0.40, blue: 0.95))
    }
    .buttonStyle(.plain)
    .cornerRadius(6)
  }
}

struct DiscordAuthButton_Previews: PreviewProvider {
  static var previews: some View {
    DiscordAuthButton(action: {})
  }
}

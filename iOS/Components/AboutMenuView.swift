//
//  AboutMenuView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 24/03/2023.
//

import SwiftUI

struct AboutMenuView: View {
  @Environment(\.openURL) var openURL
  
  var body: some View {
    Menu {
      Button(action: { openURL(URL(string: "https://mochi.gg")!) }) {
        Label("About us", image: "ico_compass")
      }
      Button(action: { openURL(URL(string: "https://twitter.com/mochi_gg_")!) }) {
        Label("Follow on twitter", image: "ico_twitter")
      }
      Button(action: { openURL(URL(string: "https://github.com/consolelabs/mochi-ios")!) }) {
        Label("Help contribute", image: "ico_github")
      }
      Button(action: { openURL(URL(string: "mailto:gm@console.so")!) }) {
        Label("Email us", image: "ico_email")
      }
    } label: {
      Image(systemName: "ellipsis")
        .font(.system(size: 11))
        .foregroundColor(Theme.text1)
        .frame(width: 32, height: 32)
        .background(Circle().foregroundColor(Theme.text5))
    }
  }
}

struct AboutMenuView_Previews: PreviewProvider {
  static var previews: some View {
    AboutMenuView()
  }
}

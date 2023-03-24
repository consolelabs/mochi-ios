//
//  SocialLabel.swift
//  Mochi
//
//  Created by Oliver Le on 28/01/2023.
//

import SwiftUI

struct SocialInfo: Identifiable {
  let id: String
  let icon: String
  let name: String
}

struct SocialLabel: View {
  // MARK: - State
  let item: SocialInfo
  
  // MARK: - Body
  var body: some View {
    HStack(spacing: 8) {
      Image(item.icon)
        .resizable()
        .renderingMode(.template)
        .foregroundColor(Theme.text4)
        .aspectRatio(contentMode: .fit)
        .frame(width: 20, height: 20)
      Text(item.name)
        .font(.interSemiBold(size: 14))
    }
    .padding(8)
    .background(RoundedRectangle(cornerRadius: 50, style: .circular).foregroundColor(.white))
  }
}

struct SocialLabel_Previews: PreviewProvider {
  static var previews: some View {
    SocialLabel(item: SocialInfo(id: "", icon: "ico_discord", name: "mochi.eth"))
      .frame(width: 200, height: 100)
      .background(Theme.text2)
      .previewLayout(.sizeThatFits)
  }
}

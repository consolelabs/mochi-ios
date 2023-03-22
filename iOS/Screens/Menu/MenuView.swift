//
//  MenuView.swift
//  Mochi
//
//  Created by Oliver Le on 29/01/2023.
//

import SwiftUI

typealias Action = () -> Void

enum MainMenuItem: Int, CaseIterable {
  case browser
  case profile
  case quests
  case gameStore
  case settings
  
  var title: String {
    switch self {
    case .browser: return "Browser"
    case .profile: return "My Profile"
    case .quests: return "Quests"
    case .gameStore: return "Game Store"
    case .settings: return "Settings"
    }
  }
  
  var icon: Image {
    switch self {
    case .browser: return Asset.browser
    case .profile: return Asset.user
    case .quests: return Asset.quest
    case .gameStore: return Asset.game
    case .settings: return Asset.settingGray
    }
  }
  
  var action: Action {
    switch self {
    case .browser:
      return {}
    default: return {}
    }
  }
}

enum SecondaryMenuItem: Int, CaseIterable {
  case invite
  case feedback
  
  var title: String {
    switch self {
    case .invite: return "Invite friends"
    case .feedback: return "Feedback"
    }
  }
  
  var icon: Image {
    switch self {
    case .invite: return Asset.addFriend
    case .feedback: return Asset.star
    }
  }
  var action: Action {
    switch self {
    case .invite:
      return {}
    case .feedback:
      return {}
    }
  }
}

struct MenuView: View {
  // MARK: - State
  @EnvironmentObject var appStateManager: AppStateManager
  private let bannerHeight: CGFloat = 120

  // MARK: - Body
  var body: some View {
    ZStack {
      Theme.gray
        .ignoresSafeArea()
      ScrollView {
        VStack {
          menuItems
          appVersion
        }
        .padding(.bottom, bannerHeight)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        navbar
      }
    }
    .overlay(alignment: .bottom) {
      banner
        .padding(.bottom)
    }
  }
  
  // MARK: - Navbar
  private var navbar: some View {
    HStack(alignment: .center) {
      Asset.avatar
        .frame(width: 40, height: 40)
        .clipShape(Circle())
      Text("MOCHI")
        .font(.interBlack(size: 16))
        .foregroundColor(Theme.text1)
      +
      Text(".")
        .font(.interBlack(size: 16))
        .foregroundColor(Theme.primary)
      Spacer()
    }
  }
  
  // MARK: - Menu item
  private var menuItems: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(MainMenuItem.allCases, id: \.self) { item in
        menuButton(icon: item.icon, title: item.title, action: item.action)
      }
      Divider()
      ForEach(SecondaryMenuItem.allCases, id: \.self) { item in
        menuButton(icon: item.icon, title: item.title, action: item.action)
      }
      Divider()
      menuButton(icon: Asset.logout, title: "Logout") {
        appStateManager.logOut()
      }
    }
  }
  
  // MARK: - Bottom Banner
  private var banner: some View {
    HStack {
      Asset.qrcode
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 80, height: 80)
      VStack(alignment: .leading, spacing: 6) {
        HStack {
          Text("NEW")
            .font(.inter(size: 10, weight: .semibold))
            .foregroundColor(Theme.green2)
            .padding(.horizontal, 2)
            .padding(.vertical, 1)
            .background(
              RoundedRectangle(cornerRadius: 2, style: .continuous)
                .foregroundColor(Theme.text1)
            )
          Text("Hunger Game")
            .font(.inter(size: 16, weight: .bold))
            .foregroundColor(Theme.text1)
        }
        Text("Challenge your friends to a puzzle game.")
          .font(.inter(size: 12, weight: .medium))
          .foregroundColor(Theme.text1)
      }
      Text("Play now")
        .font(.interSemiBold(size: 14))
        .foregroundColor(Theme.primary)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
          RoundedRectangle(cornerRadius: 8, style: .continuous)
            .foregroundColor(.white)
        )
    }
    .padding(12)
    .background(
      LinearGradient(colors: [
        Color(red: 0.99, green: 0.74, blue: 0.78),
        Color(red: 0.83, green: 0.65, blue: 0.95)
      ], startPoint: UnitPoint(x: 0.25, y: 0.5), endPoint: UnitPoint(x: 0.75, y: 0.5))
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    )
  }
  
  private var appVersion: some View {
    Text("App version \(Bundle.main.releaseVersionNumber ?? "0") (\(Bundle.main.buildVersionNumber ?? "0"))")
      .foregroundColor(Theme.text4)
      .font(.inter(size: 12, weight: .medium))
  }
  
  // MARK: - Menu Button builder
  private func menuButton(
    icon: Image,
    title: String,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack(spacing: 20) {
        icon
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 24, height: 24)
        Text(title)
          .font(.interSemiBold(size: 16))
          .foregroundColor(Theme.text1)
        Spacer()
      }
      .padding(.vertical, 20)
      .padding(.horizontal, 40)
    }
  }
}

struct MenuView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      MenuView()
    }
  }
}

//
//  MainView.swift
//  Mochi
//
//  Created by Oliver Le on 27/01/2023.
//

import ComposableArchitecture
import SwiftUI

struct Profile {
  let id: String
  let avatar: String
  let profileName: String
}

extension Profile {
  static var mock: Self {
    return Self(id: UUID().uuidString,
                avatar: "",
                profileName: "mochi.eth"
    )
  }
}

struct MainView: View {
  // MARK: - State
  @EnvironmentObject var appState: AppStateManager
  
  @State private var showMenu = false
  @State private var showQR = false
  @State private var showEdit = false
  @State private var showEditWatchlist = false
  
  @State private var offset = CGFloat.zero
  @State private var nameOpacity: Double = 0
  
  @ObservedObject var watchlistVM: WatchlistViewModel
  @ObservedObject var profileVM: ProfileViewModel
  
  private let timer = Timer.publish(every: 15, tolerance: 1, on: .main, in: .common).autoconnect()
  
  private var profile: Profile? {
    appState.profile
  }
  
  private var profileName: String {
    return profile?.profileName ?? "NA"
  }
  
  private var avatar: String {
    return profile?.avatar ?? ""
  }
  
  private let screenYOffset: CGFloat = -30
  
  // MARK: - Body
  var body: some View {
    NavigationView {
      ZStack {
        Theme.gray
          .ignoresSafeArea()
        ScrollView {
          NavigationLink(destination: MenuView(), isActive: $showMenu) {
            Color.clear
          }
          .frame(height: .zero)
          VStack(spacing: 0) {
            header
            Spacer(minLength: 14)
            socialLabelGroup
            Spacer(minLength: 2)
            walletSection
            //            Spacer(minLength: 4)
            //            nftSection
            Spacer(minLength: 4)
            watchlistSection
          }
          .offset(y: screenYOffset)
          .background(GeometryReader {
            Color.clear.preference(key: ViewOffsetKey.self,
                                   value: -$0.frame(in: .named("scroll")).origin.y)
          })
          .onPreferenceChange(ViewOffsetKey.self) { offset in
            let hiddenNameOffset = 190.0
            self.nameOpacity = 1 - (hiddenNameOffset - offset) / hiddenNameOffset
          }
        }
        .coordinateSpace(name: "scroll")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            navbar
          }
        }
        .sheet(isPresented: $showQR) {
          QRView()
        }
        .refreshable {
          Task {
            await withTaskGroup(of: Void.self) { group in
              group.addTask {
                await profileVM.fetchProfile(shouldShowLoading: true)
              }
              group.addTask {
                await watchlistVM.fetchWatchlist(shouldShowLoading: true)
              }
            }
          }
        }
        .onReceive(timer) { timer in
          Task {
            await watchlistVM.fetchWatchlist(shouldShowLoading: false)
          }
        }
      }
    }
  }
  
  // MARK: - Navbar
  private var navbar: some View {
    HStack {
      Button(action: { showMenu.toggle() }) {
        Asset.menu
          .frame(width: 40, height: 40)
      }
      .buttonStyle(.plain)
      // Trick to align center the profile name
      Color.clear
        .frame(width: 40, height: 40)
      Spacer()
      HStack {
        AsyncImage(url: URL(string: avatar)) { phase in
          switch phase {
          case let .success(image):
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 20, height: 20)
              .clipShape(Circle())
          case .empty, .failure:
            Circle()
              .foregroundColor(Theme.gray)
              .frame(width: 20, height: 20)
          @unknown default:
            EmptyView()
          }
        }
        Button(action: {}) {
          HStack(spacing: 2) {
            Text(profileName)
              .foregroundColor(Theme.text1)
              .font(.inter(size: 16, weight: .bold))
            Asset.arrowDown
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 14, height: 14)
          }
        }
        .buttonStyle(.plain)
      }
      .opacity(self.nameOpacity)
      Spacer()
      HStack(spacing: 8) {
        Button(action: { showEdit.toggle() }) {
          Asset.edit
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        Button(action: { showQR.toggle() }) {
          Asset.qr
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
      }
    }
  }
  
  // MARK: - Header
  private var header: some View {
    VStack(spacing: 12) {
      profilePicture
      profileNameLabel
    }
  }
  
  // MARK: - Profile picture
  private var profilePicture: some View {
    HStack {
      AsyncImage(url: URL(string: avatar)) { phase in
        switch phase {
        case let .success(image):
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 98, height: 98, alignment: .center)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: 2))
        case .empty, .failure:
          Circle()
            .foregroundColor(Theme.gray)
            .frame(width: 98, height: 98, alignment: .center)
            .overlay(Circle().stroke(.white, lineWidth: 2))
        @unknown default:
          EmptyView()
        }
      }
    }
  }
  
  // MARK: - Profile Name
  private var profileNameLabel: some View {
    Button(action: {}) {
      HStack(spacing: 2) {
        Text(profileName)
          .foregroundColor(Theme.text1)
          .font(.inter(size: 22, weight: .bold))
        Asset.arrowDown
          .frame(width: 20, height: 20)
      }
    }
    .buttonStyle(.plain)
  }
  
  // MARK: - Social Label Group
  private var socialLabelGroup: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        if profileVM.isLoading {
          ForEach(0..<5) { social in
            SocialLabel(item: .init(id: UUID().uuidString, icon: "discord", name: "username"))
          }
          .redacted(reason: .placeholder)
        } else {
          ForEach(profileVM.socials) { social in
            SocialLabel(item: social)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
    }
  }
  
  // MARK: - Wallet Section
  @ViewBuilder
  private var walletSection: some View {
    
    VStack(alignment: .leading, spacing: 2) {
      HStack(spacing: 8) {
        Asset.wallet
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 16, height: 16)
        
        (Text("My Wallet") + Text(profileVM.wallets.count > 0 ? " (\(profileVM.wallets.count))" : ""))
          .font(.inter(size: 13, weight: .bold))
          .foregroundColor(Theme.text4)
        
        Spacer()
        
        Button(action:{}) {
          Asset.setting
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
      }
      .frame(height: 40)
      
      VStack(alignment: .leading, spacing: 0) {
        if profileVM.isLoading {
          ForEach(0..<5, id: \.self) { id in
            WalletItemRow(item: .mockWithENS)
              .redacted(reason: .placeholder)
          }
        } else {
          ForEach(profileVM.wallets, id: \.id) { wallet in
            WalletItemRow(item: wallet)
          }
        }
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 16)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .circular)
          .foregroundColor(.white)
      )
    }
    .padding(.horizontal, 16)
  }
  
  // MARK: - NFT Section
  private var nftSection: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text("My NFT (5)")
        .font(.inter(size: 13, weight: .bold))
        .foregroundColor(Theme.text4)
        .frame(height: 30)
      VStack(spacing: 0) {
        ForEach(0..<5) { id in
          NFTItemRow(item: .mock)
        }
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 16)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .circular)
          .foregroundColor(.white)
      )
    }
    .padding(.horizontal, 16)
  }
  
  // MARK: - Watchlist Section
  private var watchlistSection: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(spacing: 8) {
        Asset.star
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 16, height: 16)
        Text("My Watchlist")
          .font(.inter(size: 13, weight: .bold))
          .foregroundColor(Theme.text4)
        Spacer()
        Button(action:{ showEditWatchlist = true }) {
          Asset.setting
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
      }
      .frame(height: 40)
      VStack(spacing: 8) {
        if watchlistVM.isLoading {
          ForEach(0..<5, id: \.self) { id in
            WatchlistItemRow(
              store: Store(
                initialState: id % 2 == 0 ? .mockIncrease : .mockDecrease,
                reducer: WatchlistItem()
              )
            )
            .redacted(reason: .placeholder)
          }
        } else {
          ForEach(watchlistVM.data) { item in
            WatchlistItemRow(
              store: Store(
                initialState: WatchlistItem.State(from: item),
                reducer: WatchlistItem()
              )
            )
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .fullScreenCover(isPresented: $showEditWatchlist) {
      EditWatchlistView()
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    let watchlistVM = WatchlistViewModel(defiService: DefiServiceImpl())
    let profileVM = ProfileViewModel(
      isFetchDiscord: true,
      mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl()),
      evmService: EVMServiceImp()
    )
    
    MainView(
      watchlistVM: watchlistVM,
      profileVM: profileVM
    )
    .previewDisplayName("iPhone 14 Pro")
    
    MainView(
      watchlistVM: watchlistVM,
      profileVM: profileVM
    )
    .previewDisplayName("iPhone SE (3rd generation)")
    .previewDevice("iPhone SE (3rd generation)")
  }
}

struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}

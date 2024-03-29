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
  @State private var showNotification = false
  @State private var showBottomSheet = false
  @State private var showEditWatchlist = false
  @State private var showEditProfile = false
  
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
          NavigationLink(destination: NotificationView(profileID: appState.profile?.id ?? ""), isActive: $showNotification) {
            Color.clear
          }
          .frame(height: .zero)
          VStack(spacing: 0) {
            header
            Spacer(minLength: 14)
//            socialLabelGroup
//            Spacer(minLength: 2)
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
        
        bottomSheet
      }
      .navigationTitle("Main")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: { showMenu.toggle() }) {
            Asset.menu
              .frame(width: 40, height: 40)
          }
          .buttonStyle(.plain)
        }
        ToolbarItem(placement: .principal) {
          HStack {
            AsyncImage(url: URL(string: avatar)) { phase in
              switch phase {
              case let .success(image):
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
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
            Button(action: toggleBottomSheet) {
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
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button(action: { showNotification.toggle() }) {
            Asset.alert
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 26, height: 26)
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
        // TODO:
        // Need to skip fetch watchlist if edit profile is showing.
        // Otherwise all the body will reload, and the state of edit profile view will reload as well
        // Find a way to handle this properly
        guard !showEditProfile else { return }
        Task {
          await watchlistVM.fetchWatchlist(shouldShowLoading: false)
        }
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
            .aspectRatio(contentMode: .fill)
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
    Button(action: toggleBottomSheet) {
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
 
  // MARK: - Bottom sheet
  private var bottomSheet: some View {
    // TODO: Find a way to dynamic this value?
    let offsetToHideBottomSheet: CGFloat = 300
    
    return ZStack(alignment: .bottom) {
      Color.black.opacity(showBottomSheet ? 0.2 : 0)
        .onTapGesture {
          toggleBottomSheet()
        }
      VStack(spacing: 16) {
        HStack {
          Spacer()
          Text(profile?.profileName ?? "")
            .font(.inter(size: 16, weight: .bold))
            .foregroundColor(Theme.text3)
          Spacer()
        }
        .padding(.top, 20)
        
        VStack(alignment: .leading, spacing: 0) {
          Button(action: {
            toggleBottomSheet()
          }) {
            HStack {
              Label {
                Text("Add another wallet")
                  .font(.interSemiBold(size: 18))
                  .foregroundColor(Theme.text1)
              } icon: {
                Asset.walletAdd
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 24, height: 24)
              }
              Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.vertical)
          }
         
          Button(action: {
            toggleBottomSheet()
            showEditProfile = true
          }) {
            HStack {
              Label {
                Text("Edit Profile")
                  .font(.interSemiBold(size: 18))
                  .foregroundColor(Theme.text1)
              } icon: {
                Asset.edit
                  .resizable()
                  .renderingMode(.template)
                  .aspectRatio(contentMode: .fit)
                  .foregroundColor(Theme.text4)
                  .frame(width: 24, height: 24)
              }
              Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.vertical)
          }
        }
        .padding(.bottom, 40)
      }
      .padding(.bottom, 16)
      .frame(maxWidth: .infinity)
      .background(Theme.gray)
      .cornerRadius(20, corners: [.topLeft, .topRight])
      .offset(y: showBottomSheet ? 16 : offsetToHideBottomSheet)
    }
    .ignoresSafeArea()
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
    .fullScreenCover(isPresented: $showEditProfile) {
      EditProfileView(
        vm: EditProfileViewModel(
          appState: appState,
          mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl())
        )
      )
    }
  }
  
  // MARK: - Actions
  
  private func toggleBottomSheet() {
    withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
      self.showBottomSheet.toggle()
    }
  }
  
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    let watchlistVM = WatchlistViewModel(defiService: DefiServiceImpl())
    let profileVM = ProfileViewModel(
      mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl()),
      evmService: EVMServiceImp()
    )
    
    MainView(
      watchlistVM: watchlistVM,
      profileVM: profileVM
    )
    .environmentObject(
      AppStateManager(
        discordService: DiscordServiceImpl(),
        keychainService: KeychainServiceImpl(),
        mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl())
      )
    )
    .previewDisplayName("iPhone 14 Pro")
    
    MainView(
      watchlistVM: watchlistVM,
      profileVM: profileVM
    )
    .environmentObject(
      AppStateManager(
        discordService: DiscordServiceImpl(),
        keychainService: KeychainServiceImpl(),
        mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl())
      )
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

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape( RoundedCorner(radius: radius, corners: corners) )
  }
}

struct RoundedCorner: Shape {
  
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}

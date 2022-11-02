//
//  ProfileView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 12/07/2022.
//

import SwiftUI
import BottomSheet

struct ProfileView: View {
  @Environment(\.openURL) var openURL
  @StateObject private var vm = ProfileViewModel()
  @State private var showSettings = false
  
  let defaultEmoticon = "😀"
  let defaultWalletName = "My Wallet"
  let defaultAddress = "0x1234...5678"
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          profileSection(
            emoticon: defaultEmoticon,
            name: defaultWalletName,
            address: defaultAddress
          )
          .padding(.bottom)
          
          buttonsSection()
        
          VStack {
            factionSection()
            
            HStack {
              randomSection()
              randomSection()
            }
          }
          .mask(RoundedRectangle(cornerRadius: 32, style: .continuous))
          .blur(radius: 20)
          .overlay {
            Text("Comming soon")
              .font(.headline)
              .foregroundColor(.title)
          }
        }
//        .halfSheet(showSheet: $appState.showSelectWallet) {
//          SelectWalletView()
//            .environmentObject(appState)
//        }
        .padding()
        .navigationBarTitle("Profile", displayMode: .inline)
        .navigationBarHidden(true)
      }
      .sheet(isPresented: $showSettings, content: {
        SettingsView()
      })
      .onChange(of: vm.url) { url in
        if let url = url {
          openURL(url)
        }
      }
    }
  }
  
  func profileSection(
    emoticon: String,
    name: String,
    address: String
  ) -> some View {
    HStack {
      Text(emoticon)
        .font(.system(size: 20))
        .frame(width: 40, height: 40)
        .background(Color.yellow)
        .clipShape(Circle())
      
      VStack(alignment: .leading) {
        Text(name)
          .font(.title.weight(.medium))
          .foregroundColor(.title)
        Text(address)
          .lineLimit(1)
          .truncationMode(.middle)
          .font(.footnote)
          .foregroundColor(.subtitle)
          .frame(width: 100, alignment: .leading)
      }
      
      Spacer()
    }
  }
  
  func buttonsSection() -> some View {
    HStack(spacing: 32) {
      TopImageButton(title: "Settings", imageName: "gearshape.fill" ) {
        self.showSettings.toggle()
      }
      
      TopImageButton(title: "Help", imageName: "questionmark") {
        openURL(URL(string: "http://getmochi.co/")!)
      }
      
      TopImageButton(title: "Wallets", imageName: "wallet.pass.fill") {
//        appState.showSelectWallet.toggle()
      }
    }
  }
  
  func factionSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Factions")
          .foregroundColor(.title)
          .font(.subheadline.weight(.semibold))
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundColor(.subtitle)
          .font(.caption2.weight(.semibold))
      }
      .padding(.horizontal)
      
      Divider()
      HStack {
        Circle()
          .foregroundColor(.gray)
          .frame(width: 40, height: 40)
        
        VStack {
          Text("Your Faction")
            .font(.subheadline.weight(.medium))
            .foregroundColor(.subtitle)
          Text("None")
            .font(.body.weight(.semibold))
            .foregroundColor(.title)
        }
        
        VStack {
          Text("Your Rank")
            .font(.subheadline.weight(.medium))
            .foregroundColor(.subtitle)
          Text("n/a")
            .font(.body.weight(.semibold))
            .foregroundColor(.title)
        }
        
        VStack {
          Text("Season")
            .font(.subheadline.weight(.medium))
            .foregroundColor(.subtitle)
          Text("---")
            .font(.body.weight(.semibold))
            .foregroundColor(.title)
        }
      }
      .padding(.horizontal)
    }
    .padding(.vertical)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .circular)
        .foregroundColor(.title.opacity(0.1))
    )
  }
  
  func randomSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Section Name")
          .foregroundColor(.title)
          .font(.subheadline.weight(.semibold))
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundColor(.subtitle)
          .font(.caption2.weight(.semibold))
      }
      .padding(.horizontal)
      
      Divider()
      
      HStack {
        VStack {
          Text("Title")
            .font(.subheadline.weight(.medium))
            .foregroundColor(.subtitle)
          Text("---")
            .font(.body.weight(.semibold))
            .foregroundColor(.title)
        }
        
        VStack {
          Text("Title")
            .font(.subheadline.weight(.medium))
            .foregroundColor(.subtitle)
          Text("---")
            .font(.body.weight(.semibold))
            .foregroundColor(.title)
        }
      }
      .padding(.horizontal)
      
      VStack {
        Text("Title")
          .font(.subheadline.weight(.medium))
          .foregroundColor(.subtitle)
        Text("---")
          .font(.body.weight(.semibold))
          .foregroundColor(.title)
      }
      .padding(.horizontal)
    }
    .padding(.vertical)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .circular)
        .foregroundColor(.title.opacity(0.1))
    )
  }
  
  func rewardsSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Factions")
          .foregroundColor(.title)
          .font(.subheadline.weight(.semibold))
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundColor(.subtitle)
          .font(.caption2.weight(.semibold))
      }
      .padding(.horizontal)
      
      Divider()
      HStack {
        Circle()
          .foregroundColor(.gray)
          .frame(width: 40, height: 40)
        
        VStack {
          Text("Your Faction")
            .font(.subheadline.weight(.medium))
            .foregroundColor(.subtitle)
          Text("None")
            .font(.body.weight(.semibold))
            .foregroundColor(.title)
        }
        
        VStack {
          Text("Your Rank")
            .font(.subheadline.weight(.medium))
            .foregroundColor(.subtitle)
          Text("n/a")
            .font(.body.weight(.semibold))
            .foregroundColor(.title)
        }
        
        VStack {
          Text("Season")
            .font(.subheadline.weight(.medium))
            .foregroundColor(.subtitle)
          Text("---")
            .font(.body.weight(.semibold))
            .foregroundColor(.title)
        }
      }
      .padding(.horizontal)
    }
    .padding(.vertical)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .circular)
        .foregroundColor(.title.opacity(0.1))
    )
  }
  
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
  }
}

struct TopImageButton: View {
  enum Style {
    case primary
    case secondary
  }
  
  typealias Action = () -> Void
  
  let title: String
  let imageName: String
  let style: Style
  let action: Action
  
  init(title: String, imageName: String, style: Style = .secondary, action: @escaping Action) {
    self.title = title
    self.imageName = imageName
    self.style = style
    self.action = action
  }
  
  var body: some View {
    Button(action: action) {
      VStack {
        Image(systemName: imageName)
          .foregroundColor(.neutral1)
          .frame(width: 40, height: 40)
          .background(style == .primary ? Color.appPrimary : Color.subtitle)
          .clipShape(Circle())
        
        Text(title)
          .font(.footnote.weight(.medium))
          .foregroundColor(.subtitle)
      }
    }
  }
}

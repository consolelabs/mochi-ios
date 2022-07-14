//
//  ProfileView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 12/07/2022.
//

import SwiftUI

struct ProfileView: View {
  let profilePictureUrl = ""
  let name = "Your name"
  let address = "0x1234...5678"
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          profileSection(
            profilePictureUrl: profilePictureUrl,
            name: name,
            address: address
          )
          .padding(.bottom)
          
          buttonsSection()
          
          factionSection()
          
          HStack {
            randomSection()
            randomSection()
          }
          
          leaderBoardSection()
        }
        .padding()
      }
      .navigationBarTitle("Profile", displayMode: .inline)
      .navigationBarHidden(true)
    }
  }
 
  func profileSection(
    profilePictureUrl: String,
    name: String,
    address: String
  ) -> some View {
    HStack {
      AsyncImage(url: URL(string: profilePictureUrl)) { image in
        image
          .resizable()
          .clipShape(RoundedRectangle(cornerRadius: 4))
      } placeholder: {
        Circle()
          .foregroundColor(.gray)
      }
      .aspectRatio(contentMode: .fit)
      .frame(width: 50, height: 50, alignment: .center)
      
      VStack(alignment: .leading) {
        Text(name)
          .font(.title.weight(.medium))
          .foregroundColor(.title)
        Text(address)
          .font(.footnote)
          .foregroundColor(.subtitle)
      }
      
      Spacer()
    }
  }
  
  func buttonsSection() -> some View {
    HStack(spacing: 32) {
      TopImageButton(title: "Settings", imageName: "gearshape.fill" ) {
        
      }
      
      TopImageButton(title: "Help", imageName: "questionmark") {
        
      }
      
      TopImageButton(title: "Wallets", imageName: "wallet.pass.fill") {
        
      }
      
      TopImageButton(title: "Connect", imageName: "play.fill", style: .primary) {
        
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
  
  func leaderBoardSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Leaderboards")
          .foregroundColor(.title)
          .font(.subheadline.weight(.semibold))
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundColor(.subtitle)
          .font(.caption2.weight(.semibold))
      }
      .padding(.horizontal)
      
      Divider()
      
      GeometryReader { proxy in
        VStack {
          HStack {
            Text("Rank")
              .font(.subheadline.weight(.medium))
              .foregroundColor(.subtitle)
              .frame(width: proxy.size.width * 1 / 5, alignment: .leading)
            
            Text("Username")
              .font(.subheadline.weight(.medium))
              .foregroundColor(.subtitle)
              .frame(width: proxy.size.width * 2 / 5, alignment: .leading)
            
            Text("30d P&L")
              .font(.subheadline.weight(.medium))
              .foregroundColor(.subtitle)
              .frame(width: proxy.size.width * 2 / 6, alignment: .trailing)
          }
          
          ForEach(0...4, id: \.self) { item in
            HStack {
              Text("\(item + 1)")
                .font(.body.weight(.medium))
                .foregroundColor(.title)
                .frame(width: proxy.size.width * 1 / 5, alignment: .leading)
              
              Text("0x1234...5678")
                .font(.body.weight(.medium))
                .foregroundColor(.title)
                .frame(width: proxy.size.width * 2 / 5, alignment: .leading)
              
              Text("134,567%")
                .font(.body.weight(.medium))
                .foregroundColor(.title)
                .frame(width: proxy.size.width * 2 / 6, alignment: .trailing)
            }
          }
        }
      }
      .padding(.horizontal)
    }
    .padding(.vertical)
    .frame(height: 185)
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

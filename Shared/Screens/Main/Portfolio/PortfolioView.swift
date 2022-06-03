//
//  Portfolio.swift
//  Bitsfi
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI

struct PortfolioView: View {
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          AccountInfoView()
          NftGeneralInfoView()
          VStack(alignment: .leading) {
            Text("Collectibles")
              .bold()
              .font(.title2)
              .foregroundColor(.title)
          }
        }
        .padding()
      }
    }
  }
}

struct PortfolioView_Previews: PreviewProvider {
  static var previews: some View {
    PortfolioView()
  }
}

struct AccountInfoView: View {
  var body: some View {
    HStack {
      RoundedRectangle(cornerRadius: 10)
        .frame(width: 40, height: 40)
        .foregroundColor(.cyan)
      VStack(alignment: .leading) {
        Text("My account")
          .bold()
        Text("1FfmbHfnpaZjKFvyi1okTjJJusN455paPH")
          .foregroundColor(.gray)
          .lineLimit(1)
          .truncationMode(.middle)
        HStack {
          HStack {
            Text("23")
              .foregroundColor(Color.purple)
            Text("Follower")
          }
          HStack {
            Text("124")
              .foregroundColor(Color.purple)
            Text("Following")
          }
        }
      }
    }
  }
}

struct NftGeneralInfoView: View {
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack {
        // Total NFT
        HStack {
          VStack {
            Circle()
              .frame(width: 32, height: 32)
            Spacer()
          }
          
          VStack(alignment: .leading) {
            Text("Total NFT")
              .font(.headline)
              .foregroundColor(.title)
            
            HStack {
              Text("In Wallet")
                .foregroundColor(.subtitle)
              Text("7")
            }
            HStack {
              HStack {
                Text("Staked")
                  .foregroundColor(.subtitle)
                Text("03")
              }
              HStack {
                Text("Listing")
                  .foregroundColor(.subtitle)
                Text("04")
              }
            }
          }
          
          Text("49")
            .bold()
            .font(.title2)
            .padding()
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.neutral1)
        )
        
        // Total Collections
        HStack {
          VStack {
            Circle()
              .frame(width: 32, height: 32)
            Spacer()
          }
          
          VStack(alignment: .leading) {
            Text("Total Collections")
              .font(.headline)
              .foregroundColor(.title)
            
            HStack {
              Text("Most Holding")
                .foregroundColor(.subtitle)
              HStack {
                Circle()
                  .frame(width: 20, height: 20)
                Text("Sipher")
                  .foregroundColor(.appPrimary)
              }
            }
          }
          
          Text("2")
            .bold()
            .font(.title2)
            .padding()
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.neutral1)
        )
        
        // Net Worths
        HStack {
          Circle()
            .frame(width: 32, height: 32)
          
          Text("Net Worths")
            .font(.headline)
            .foregroundColor(.title)
          
          Spacer()
          
          Text("$14,436")
            .bold()
            .font(.title2)
            .padding()
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.neutral1)
        )
      }
    }
  }
}

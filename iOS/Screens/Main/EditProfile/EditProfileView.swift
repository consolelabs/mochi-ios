//
//  EditProfileView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 29/03/2023.
//

import SwiftUI

struct EditProfileView: View {
  @Environment(\.dismiss) var dismiss
    
  @ObservedObject var vm: EditProfileViewModel
  
  var body: some View {
    NavigationView {
      ZStack {
        Theme.gray
          .ignoresSafeArea()
        ScrollView {
          avatar
          Spacer(minLength: 40)
          usernameField
            .padding(.horizontal, 16)
        }
        .padding(.top, 8)
      }
      .onReceive(vm.$shouldDismiss) { shouldDismiss in
        if shouldDismiss {
          dismiss()
        }
      }
      .navigationTitle("Edit Profile")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Edit Profile")
            .foregroundColor(Theme.text1)
            .font(.inter(size: 16, weight: .bold))
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: { dismiss() }) {
            Text("Cancel")
              .foregroundColor(Theme.text1)
              .font(.inter(size: 16, weight: .medium))
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            Task(priority: .high) {
              await vm.save()
            }
          }) {
            Text("Save")
              .foregroundColor(Theme.text1)
              .font(.inter(size: 16, weight: .semibold))
          }
        }
      }
    }
  }
  
  private var avatar: some View {
    VStack(spacing: 12) {
      AsyncImage(url: URL(string: vm.avatar)) { phase in
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
      .overlay {
        Circle()
          .frame(width: 100, height: 100)
          .foregroundColor(Theme.text1.opacity(0.15))
      }
      .overlay {
        Asset.camera
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 24, height: 24)
      }
      Text("Upload Profile Photo")
        .font(.inter(size: 14))
        .foregroundColor(Theme.text1)
    }
    .padding(.top, 16)
  }
  
  private var usernameField: some View {
    VStack(alignment: .leading) {
      Text("Username")
        .font(.interSemiBold(size: 16))
        .foregroundColor(Theme.text1)
      
      HStack(spacing: 0) {
        Text("mochi.gg/")
          .foregroundColor(Theme.text6)
          .padding(.vertical, 8)
          .padding(.horizontal, 12)
          .frame(maxHeight: .infinity)
          .background(
            Theme.text5
          )
        TextField("username", text: $vm.username)
          .font(.inter(size: 15))
          .foregroundColor(Theme.text1)
          .padding(8)
      }
      .frame(height: 48)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
  }
}

struct EditProfileView_Previews: PreviewProvider {
  static var previews: some View {
    EditProfileView(
      vm: EditProfileViewModel(
        appState: AppStateManager(
          discordService: DiscordServiceImpl(),
          keychainService: KeychainServiceImpl(),
          mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl())
        ),
        mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl())
      )
    )
  }
}

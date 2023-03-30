//
//  EditProfileViewModel.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 29/03/2023.
//

import Foundation
import OSLog

@MainActor
final class EditProfileViewModel: ObservableObject {
  @Published var username: String
  @Published var avatar: String {
    didSet {
      self.logger.info("Avatar: \(self.avatar)")
    }
  }
  var avatarURL: URL? {
    URL(string: avatar)
  }
  @Published var isLoading: Bool = false
  @Published var isLoadingAvatar: Bool = false
  @Published var error: String? = nil
  @Published var shouldDismiss: Bool = false
  
  private let mochiProfileService: MochiProfileService
  private let appState: AppStateManager
  private let logger = Logger(subsystem: "so.console.mochi", category: "EditProfileViewModel")
  
  init(appState: AppStateManager, mochiProfileService: MochiProfileService) {
    self.appState = appState
    self.username = appState.profile?.profileName ?? ""
    self.avatar = appState.profile?.avatar ?? ""
    self.mochiProfileService = mochiProfileService
  }
 
  func uploadImage(data: Data?) {
    guard let data else {
      logger.error("invalid image data")
      return
    }
    
    Task(priority: .high) {
      isLoadingAvatar = true
      let result = await mochiProfileService.uploadImage(data: data.bytes, imageName: UUID().uuidString)
      isLoadingAvatar = false
      switch result {
      case let .failure(error):
        logger.error("upload image failed, error: \(error)")
      case let .success(resp):
        avatar = resp.data.url
      }
    }
  }
  
  func save() async {
    isLoading = true
    
    let result = await mochiProfileService.updateInfo(avatar: avatar, profileName: username)
    
    isLoading = false
    
    switch result {
    case let .failure(error):
      self.error = error.customMessage
      logger.error("update info failed, error: \(error)")
    case let .success(resp):
      appState.profile = Profile(id: resp.id, avatar: resp.avatar, profileName: resp.profileName)
      shouldDismiss = true
    }
  }
}

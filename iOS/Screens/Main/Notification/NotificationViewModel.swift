//
//  NotificationViewModel.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/03/2023.
//

import Foundation
import OSLog

@MainActor
final class NotificationViewModel: ObservableObject {
  @Published var items: [NotificationItem]
  @Published var isLoading: Bool
  
  private let profileID: String
  
  private let mochiProfileService: MochiProfileService
  private let logger = Logger(subsystem: "so.console.mochi", category: "NotificationViewModel")
  
  init(
    profileID: String,
    mochiProfileService: MochiProfileService,
    items: [NotificationItem] = [],
    isLoading: Bool = false
  ) {
    self.mochiProfileService = mochiProfileService
    self.profileID = profileID
    self.items = items
    self.isLoading = isLoading
  }
  
  func fetchNotifications() async {
    isLoading = true
    
    let result = await mochiProfileService.getActivities(profileId: profileID, page: 0, size: 100)
    
    isLoading = false
    
    switch result {
    case let .failure(error):
      logger.error("fetch notification error: \(error)")
    case let .success(resp):
      self.items = resp.data.map(NotificationItem.init(from:))
    }
  }
    
  func markRead(id: Int) async {
    guard
      let index = items.firstIndex(where: { $0.id == id }),
      !items[index].isRead
    else {return}
    
    items[index].isRead = true
    
    await markRead(ids: [id])
  }
  
  func markReadAll() async {
    let ids = items.map { $0.id }
    await markRead(ids: ids, shouldReload: true)
  }
  
  private func markRead(ids: [Int], shouldReload: Bool = false) async {
    let result = await mochiProfileService.readActivities(profileId: profileID, ids: ids)
    switch result {
    case let .failure(error):
      logger.error("mark read failed, error: \(error)")
    case .success:
      if shouldReload {
        await self.fetchNotifications()
      }
    }
  }
}

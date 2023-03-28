//
//  NotificationView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 28/03/2023.
//

import SwiftUI

struct NotificationItem: Identifiable {
  let id: Int
  let title: String
  let date: String
  let icon: String
  var isRead: Bool
}

extension NotificationItem {
  init(from model: GetActivityData) {
    self.id = model.id
    self.title = model.actionDescription
    self.isRead = model.status == .read
    let dateFormmater = DateFormatter()
    dateFormmater.dateFormat = "MMM d, h:mm a"
    self.date = dateFormmater.string(from: model.createdAt)
    switch model.action {
    case .some(.tip): self.icon = "ico_tip"
    case .some(.gift): self.icon =  "ico_gift"
    case .some(.quest): self.icon = "ico_quest"
    default: self.icon = "ico_alert"
    }
  }
  
  static var mock: Self {
    return NotificationItem(
      id: 0,
      title: "@anhnh has given you a tip of 0.1 FTM",
      date: "Feb 6, 4:28pm",
      icon: "ico_alert",
      isRead: true
    )
  }
}

struct NotificationView: View {
  @StateObject private var vm: NotificationViewModel
  init(profileID: String, items: [NotificationItem] = [], isLoading: Bool = false) {
    self._vm = StateObject(
      wrappedValue: NotificationViewModel(
        profileID: profileID,
        mochiProfileService: MochiProfileServiceImp(keychainService: KeychainServiceImpl()),
        items: items,
        isLoading: isLoading
      )
    )
  }
  
  var body: some View {
    ZStack {
      Theme.gray
        .ignoresSafeArea()
      ScrollView {
        VStack(spacing: 0) {
          if (vm.isLoading) {
            ForEach(0..<10, id: \.self) { id in
              notificationRow(item: .mock)
            }
            .redacted(reason: .placeholder)
          } else {
            ForEach(vm.items) { item in
              notificationRow(item: item)
            }
          }
        }
      }
      .refreshable {
        await vm.fetchNotifications()
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Notifications")
          .font(.inter(size: 16, weight: .bold))
          .foregroundColor(Theme.text1)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
          Button(action: {
            Task(priority: .high) {
              await vm.markReadAll()
            }
          }) {
            Label("Mark all as read", systemImage: "checkmark.circle")
          }
        } label: {
          Image(systemName: "ellipsis")
            .font(.system(size: 11))
            .foregroundColor(Theme.text1)
            .frame(width: 32, height: 32)
            .background(Circle().foregroundColor(Theme.text5))
        }
      }
    }
    .task {
      await vm.fetchNotifications()
    }
  }
  
  private func notificationRow(item: NotificationItem) -> some View {
    Button(action: {
      Task(priority: .high) {
        await vm.markRead(id: item.id)
      }
    }) {
    HStack {
      ZStack(alignment: .topTrailing) {
        Image(item.icon)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 24, height: 24)
          .frame(width: 48, height: 48)
          .background(Color(red: 0.84, green: 0.84, blue: 0.85))
          .clipShape(Circle())
        if !item.isRead {
          Circle()
            .frame(width: 8, height: 8)
            .foregroundColor(Theme.red)
        }
      }
      VStack(alignment: .leading, spacing: 3) {
        Text(item.title)
          .font(.inter(size: 16, weight: .medium))
          .foregroundColor(Theme.text1)
        Text(item.date)
          .font(.inter(size: 12, weight: .medium))
          .foregroundColor(Theme.text3)
      }
      Spacer()
    }
    .padding(.vertical, 12)
    .padding(.horizontal)
    }
  }
}

struct NotificationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      NotificationView(profileID: "", items: [
        .mock,
        .mock,
        .mock,
      ])
    }
   
    NavigationView {
      NotificationView(profileID: "", items: [], isLoading: true)
    }
    .previewDisplayName("loading")
  }
}

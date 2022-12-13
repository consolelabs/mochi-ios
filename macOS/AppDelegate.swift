//
//  AppDelegate.swift
//  Mochi Wallet (macOS)
//
//  Created by Oliver Le on 30/10/2022.
//

import Foundation
import AppKit
import UserNotifications
import OSLog

final class AppDelegate: NSObject, NSApplicationDelegate {
  private lazy var priceAlertService = PriceAlertServiceImpl()
  private let logger = Logger(subsystem: "so.console.mochi", category: "AppDelegate")
  
  // MARK: - NSApplicationDelegate
  func applicationDidFinishLaunching(_ notification: Notification) {
    UNUserNotificationCenter.current().delegate = self
  }
  
  func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    let deviceId = Util.hardwareUUID() ?? ""
    logger.debug("Successfully registered for notifications! Device token: \(token)")
    
    Task {
      await priceAlertService.upsertUserDevicePushToken(deviceId: deviceId, pushToken: token)
    }
  }
  
  func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    logger.error("Failed to register for notifications: \(error.localizedDescription)")

  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.list, .sound, .badge, .banner])
  }
}

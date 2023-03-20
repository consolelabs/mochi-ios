//
//  AppDelegate.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 17/11/2022.
//

import UIKit
import OSLog

class AppDelegate: NSObject, UIApplicationDelegate {
  private lazy var priceAlertService = PriceAlertServiceImpl()
  private let logger = Logger(subsystem: "so.console.mochi", category: "AppDelegate")
 
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    UIApplication.shared.registerForRemoteNotifications()
    UNUserNotificationCenter.current().delegate = self
    return true
  }
  
  // No callback in simulator
  // must use device to get valid push token
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // send device token to server
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    let deviceId = UIDevice().identifierForVendor?.uuidString ?? ""
    logger.debug("Successfully registered for notifications! Device token: \(token)")
    
    Task {
      await priceAlertService.upsertUserDevicePushToken(deviceId: deviceId, pushToken: token)
    }
  }
  
  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    logger.error("Failed to register for notifications: \(error.localizedDescription)")
  }
  
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.badge, .banner, .list, .sound])
  }
}


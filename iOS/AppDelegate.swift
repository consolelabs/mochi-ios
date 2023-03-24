//
//  AppDelegate.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 17/11/2022.
//

import UIKit
import OSLog
import WalletConnectRelay
import WalletConnectNetworking

class AppDelegate: NSObject, UIApplicationDelegate {
  private let logger = Logger(subsystem: "so.console.mochi", category: "AppDelegate")
 
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    registerRemoteNotification()
    return true
  }
  
  // No callback in simulator
  // must use device to get valid push token
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    let deviceId = UIDevice().identifierForVendor?.uuidString ?? ""
    logger.debug("Successfully registered for notifications! Device token: \(token)")
    let priceAlertService = PriceAlertServiceImpl()
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
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Determine who sent the URL.
    let sendingAppID = options[.sourceApplication]
    print("source application = \(sendingAppID ?? "Unknown")")
    
    // Process the URL.
    guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else  {
      print("Invalid URL or album path missing")
      return false
    }
    print(components)
    return true
  }
  
//  private func configConnectWallet() {
//    Networking.configure(projectId: InputConfig.projectId, socketFactory: DefaultSocketFactory())
//    Auth.configure(signerFactory: DefaultSignerFactory())
//  }
 
  private func registerRemoteNotification() {
    UIApplication.shared.registerForRemoteNotifications()
    UNUserNotificationCenter.current().delegate = self
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.badge, .banner, .list, .sound])
  }
}

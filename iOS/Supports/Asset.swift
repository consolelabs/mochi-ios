//
//  Asset.swift
//  Mochi
//
//  Created by Oliver Le on 26/01/2023.
//

import Foundation
import SwiftUI

enum Asset {
  // Images
  static let avatar = Image("avatar")
  static let rocket = Image("Rocket")
  static let profilePic = Image("profile_pic")
  static let qrcode = Image("qrcode")
  static let metamask = Image("metamask")
  static let walletconnect = Image("walletconnect")
  static let coinbase = Image("coinbase")
  
  // Icons
  static let discord = Image("ico_discord")
  static let twitter = Image("ico_twitter")
  static let telegram = Image("ico_telegram")
  static let google = Image("ico_google")
  static let solana = Image("ico_solana")
  static let ethereum = Image("ico_ethereum")
  static let edit = Image("ico_edit")
  static let qr = Image("ico_qr")
  static let menu = Image("ico_menu")
  static let arrowDown = Image("ico_arrowdown")
  static let arrowRight = Image("ico_arrow_right")
  static let setting = Image("ico_setting")
  static let increase = Image("ico_increase")
  static let decrease = Image("ico_decrease")
  static let copy = Image("ico_copy")
  static let share = Image("ico_share")
  static let browser = Image("ico_browser")
  static let quest = Image("ico_quests")
  static let user = Image("ico_user")
  static let game = Image("ico_game")
  static let settingGray = Image("ico_setting_gray")
  static let addFriend = Image("ico_add_friend")
  static let star = Image("ico_star")
  static let logout = Image("ico_logout")
  
}

enum Theme {
  static let blue = Color("Blue")
  static let gray = Color("Gray")
  static let green1 = Color("Green1")
  static let green2 = Color("Green2")
  static let orange = Color("Orange")
  static let purple = Color("Purple")
  static let red = Color("Red")
  static let yellow = Color("Yellow")
  static let primary = Color("Primary")
  
  static let text1 = Color("Text1")
  static let text2 = Color("Text2")
  static let text3 = Color("Text3")
  static let text4 = Color("Text4")
  static let text5 = Color("Text5")
}

extension Font {
  static func boldSora(size: CGFloat) -> Font {
    return .custom("Sora-Bold", size: size)
  }
  
  static func inter(size: CGFloat, weight: Weight = .regular) -> Font {
    var name = "Inter-Regular"
    switch weight {
    case .semibold, .medium:
      name = "Inter-SemiBold"
    case .bold:
      name = "Inter-Bold"
    case .black, .heavy:
      name = "Inter-Black"
    default:
      name = "Inter-Regular"
    }
    return .custom(name, size: size)
  }
  
  static func interBlack(size: CGFloat) -> Font {
    return .custom("Inter-Black", size: size)
  }
  
  static func interSemiBold(size: CGFloat) -> Font {
    return .custom("Inter-SemiBold", size: size)
  }
}

extension UIFont {
  public class func boldSoraFont(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: "Sora-Bold", size: fontSize) ?? .boldSystemFont(ofSize: fontSize)
  }
  
  public class func interFont(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: "Inter-Regular", size: fontSize) ?? .systemFont(ofSize: fontSize)
  }
  
  public class func interBlackFont(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: "Inter-Black", size: fontSize) ?? .systemFont(ofSize: fontSize)
  }
}


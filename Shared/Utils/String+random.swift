//
//  String+random.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 24/03/2023.
//

import Foundation

extension String {
  static func random(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
  }
}

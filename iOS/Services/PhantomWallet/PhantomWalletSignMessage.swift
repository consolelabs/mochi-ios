//
//  PhantomWalletSignMessage.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 24/03/2023.
//

import Foundation

struct PhantomWalletSignMessageApprovePayload: Decodable {
  /// The message signature, encoded in base58.
  ///
  /// For more information on how to verify the signature of a message, please refer to Encryption Resources.
  /// https://docs.phantom.app/phantom-deeplinks/encryption#encryption-resources
  let signature: String
}

struct PhantomWalletSignMessagePayload: Encodable {
  enum DisplayEncoding: String, Encodable {
    case utf8
    case hex
  }
 
  /// The message, base58 encoded
  let message: String
  
  /// Token received from connect-method
  let session: String
  
  /// The encoding to use when displaying the message
  let display: DisplayEncoding
}

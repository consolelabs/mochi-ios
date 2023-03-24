//
//  PhantomWalletResponse.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 24/03/2023.
//

import Foundation
import TweetNacl

enum PhantomConnectResult {
  case approve(payload: PhantomConnectApprovePayload)
  case reject(error: PhantomConnectReject)
}

struct PhantomConnectReject {
  
}

struct PhantomConnectApprovePayload {
  
  struct PhantomConnectApproveData: Decodable {
    /// base58 encoding of user public key
    let publicKey: String
    
    /// session token for subsequent signatures and messages
    /// dapps should send this with any other deeplinks after connect
    let session: String
    
    init(encryptedData: Data, sharedSecret: Data, nonce: Data) throws {
      let decryptedData = try NaclSecretBox.open(box: encryptedData, nonce: nonce, key: sharedSecret)
      let jsonDecoder = JSONDecoder()
      jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
      let data = try jsonDecoder.decode(PhantomConnectApproveData.self, from: decryptedData)
      self.publicKey = data.publicKey
      self.session = data.session
    }
  }
  
  
  /// An encryption public key used by Phantom for the construction of a shared secret between the connecting app and Phantom, encoded in base58.
  let phantomEncryptionPublicKey: String
  
  /// A nonce used for encrypting the response, encoded in base58.
  let nonce: String
  
  
  /// An encrypted JSON string. Encrypted bytes are encoded in base58.
  ///
  /// Refer to Encryption https://docs.phantom.app/phantom-deeplinks/encryption to learn how apps can decrypt data using a shared secret.
  let data: String
  
  private (set) var decryptedData: PhantomConnectApproveData?
 
  init(queryItems: [URLQueryItem]) throws {
    var phantomEncryptionPublicKey: String?
    var nonce: String?
    var data: String?
    
    for item in queryItems {
      switch item.name {
      case "phantom_encryption_public_key":
        phantomEncryptionPublicKey = item.value
        
      case "nonce":
        nonce = item.value
        
      case "data":
        data = item.value
        
      default:
        throw MochiError.custom("unsupported query param from phantom")
      }
    }
    
    guard let phantomEncryptionPublicKey, let nonce, let data else {
      throw MochiError.custom("init phantom connect data failed")
    }
    
    self.phantomEncryptionPublicKey = phantomEncryptionPublicKey
    self.nonce = nonce
    self.data = data
  }
  
  mutating func set(decryptedData: PhantomConnectApproveData) {
    self.decryptedData = decryptedData
  }
}

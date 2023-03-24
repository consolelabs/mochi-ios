//
//  PhantomWalletService.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 24/03/2023.
//

import Foundation
import TweetNacl

enum PhantomWalletMethod {
  case connect(appURL: String, redirectLink: String)
  case sign(message: String, redirectLink: String)
}

final class PhantomWalletService {
  private typealias KeyPair = (publicKey: Data, secretKey: Data)
  
  private var dappKeyPair: KeyPair?
  private var sharedSecret: Data?
  private var session: String?
  private var walletAddress: String?
  
  init() {
    self.dappKeyPair = try? NaclBox.keyPair()
  }
  
  func getDeeplink(for method: PhantomWalletMethod) throws -> URL {
    switch method {
    case let .connect(appURL, redirectLink):
      return try getConnectDeeplink(appURL: appURL, redirectLink: redirectLink)
    case let .sign(message, redirectLink):
      return try getSignMessageDeeplink(message: message, redirectLink: redirectLink)
    }
  }
  
  func getPhantomConnectData(queryItems: [URLQueryItem]) throws -> PhantomConnectApprovePayload {
    guard var payload = try? PhantomConnectApprovePayload(queryItems: queryItems) else {
      throw MochiError.custom("connect phantom wallet failed")
    }
    guard let encryptedData = payload.data.base58DecodedData, let nonce = payload.nonce.base58DecodedData else {
      throw MochiError.custom("payload data is missing")
    }
    guard let dappSecretKey = dappKeyPair?.secretKey else {
      throw MochiError.custom("dapp key pair is not existed")
    }
    
    guard let phantomPubkey = payload.phantomEncryptionPublicKey.base58DecodedData else {
      throw MochiError.custom("invalid phantom encryption public key")
    }
    
    let sharedSecret = try NaclBox.before(publicKey: phantomPubkey, secretKey: dappSecretKey)
    let data = try PhantomConnectApprovePayload.PhantomConnectApproveData(encryptedData: encryptedData,
                                                                          sharedSecret: sharedSecret,
                                                                          nonce: nonce)
    payload.set(decryptedData: data)
    
    // TODO: store shared secret key somewhere for later usage?
    self.sharedSecret = sharedSecret
    self.session = data.session
    self.walletAddress = data.publicKey
    
    return payload
  }
  
  func getSignature(queryItems: [URLQueryItem]) throws -> String {
    guard let data = queryItems.first(where: { $0.name == "data" })?.value,
          let nonce = queryItems.first(where: { $0.name == "nonce" })?.value
    else {
      throw MochiError.custom("invalid query items")
    }
    
    guard let sharedSecret else {
      throw MochiError.custom("shared secret is not existed")
    }
    
    let payload: PhantomWalletSignMessageApprovePayload = try decryptPayload(encryptedData: data, nonce: nonce, sharedSecret: sharedSecret)
    return payload.signature
  }
  
  func getWalletAddress() throws -> String {
    guard let address = walletAddress else {
      throw MochiError.custom("user public key is not existed")
    }
    return address
  }
}


// MARK: - Private
private extension PhantomWalletService {
  private func getConnectDeeplink(appURL: String, redirectLink: String) throws -> URL {
    
    guard let dappKeyPair else {
      throw MochiError.custom("dapp key pair is not existed")
    }
    
    var urlComponent = URLComponents()
    urlComponent.scheme = "https"
    urlComponent.host = "phantom.app"
    urlComponent.path = "/ul/v1/connect"
    let queryItems: [URLQueryItem] = [
      URLQueryItem(name: "app_url", value: appURL),
      URLQueryItem(name: "dapp_encryption_public_key", value: dappKeyPair.publicKey.bytes.base58EncodedString),
      URLQueryItem(name: "redirect_link", value: redirectLink)
    ]
    urlComponent.queryItems = queryItems
    
    guard let url = urlComponent.url else {
      throw MochiError.custom("cannot compose phantom connect deeplink")
    }
    
    return url
  }
  
  private func getSignMessageDeeplink(message: String, redirectLink: String) throws -> URL {
    guard let dappKeyPair, let sharedSecret, let session else {
      throw MochiError.custom("dappkeyPair, sharedSecret, session is not existed")
    }
    let payload = PhantomWalletSignMessagePayload(
      message: message.base58EncodedString,
      session: session,
      display: .utf8
    )
    
    let (nonce, encryptedPayload) = try encryptPayload(payload: payload, sharedSecret: sharedSecret)
    
    var urlComponent = URLComponents()
    urlComponent.scheme = "https"
    urlComponent.host = "phantom.app"
    urlComponent.path = "/ul/v1/signMessage"
    let queryItems: [URLQueryItem] = [
      URLQueryItem(name: "dapp_encryption_public_key", value: dappKeyPair.publicKey.bytes.base58EncodedString),
      URLQueryItem(name: "nonce", value: nonce.bytes.base58EncodedString),
      URLQueryItem(name: "redirect_link", value: redirectLink),
      URLQueryItem(name: "payload", value: encryptedPayload.bytes.base58EncodedString)
    ]
    urlComponent.queryItems = queryItems
    guard let url = urlComponent.url else {
      throw MochiError.custom("cannot compose sign message deeplink")
    }
    return url
  }
  
  private func decryptPayload<T: Decodable>(encryptedData: String, nonce: String, sharedSecret: Data) throws -> T {
    guard
      let data = encryptedData.base58DecodedData,
      let nonceData = nonce.base58DecodedData
    else {
      throw MochiError.custom("invalid encrypted data")
    }
    let decryptedData = try NaclSecretBox.open(box: data, nonce: nonceData, key: sharedSecret)
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return try jsonDecoder.decode(T.self, from: decryptedData)
  }
  
  private func encryptPayload(payload: Encodable, sharedSecret: Data) throws -> (nonce: Data, encryptedPayload: Data) {
    let nonce = try NaclUtil.secureRandomData(count: 24)
    let jsonEncoder = JSONEncoder()
    jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
    let data = try jsonEncoder.encode(payload)
    let encryptedPayload = try NaclSecretBox.secretBox(message: data, nonce: nonce, key: sharedSecret)
    return (nonce, encryptedPayload)
  }
}

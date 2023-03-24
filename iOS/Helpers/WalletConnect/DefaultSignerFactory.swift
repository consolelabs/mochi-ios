import Foundation
import CryptoSwift
import web3swift

//public struct DefaultSignerFactory: SignerFactory {
//
//  public func createEthereumSigner() -> EthereumSigner {
//    return Web3Signer()
//  }
//}
//
//public struct Web3Signer: EthereumSigner {
//
//  public func sign(message: Data, with key: Data) throws -> EthereumSignature {
//    let password = String.
//    let privateKey = try web3swift.EthereumKeystoreV3(privateKey: key, password: <#T##String#>)
//    web3swift.keystore
//    let signature = try web3swift.Web3Signer.signPersonalMessage(<#T##personalMessage: Data##Data#>, keystore: <#T##AbstractKeystore#>, account: <#T##EthereumAddress#>, password: <#T##String#>)
////    let signature = try web3swift.Web3Signer.signPersonalMessage(message, keystore: privateKey, account: privateKey?.getAddress(), password: privateKey.pas)
////    let signature = try privateKey.sign(message: message.bytes)
//    return EthereumSignature(v: UInt8(signature.v), r: signature.r, s: signature.s)
//  }
//
//  public func recoverPubKey(signature: EthereumSignature, message: Data) throws -> Data {
//    let publicKey = try EthereumPublicKey(
//      message: message.bytes,
//      v: EthereumQuantity(quantity: BigUInt(signature.v)),
//      r: EthereumQuantity(signature.r),
//      s: EthereumQuantity(signature.s)
//    )
//    return Data(publicKey.rawPublicKey)
//  }
//
//  public func keccak256(_ data: Data) -> Data {
//    let digest = SHA3(variant: .keccak256)
//    let hash = digest.calculate(for: [UInt8](data))
//    return Data(hash)
//  }
//}

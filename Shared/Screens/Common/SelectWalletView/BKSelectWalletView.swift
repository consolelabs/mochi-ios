//
//  SelectWalletView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 15/07/2022.
//

import SwiftUI
import WalletConnectSwift

class BKSelectWalletViewModel: ObservableObject {
  private var client: Client?
  private var session: Session?
  
  @Published var wallets: [Wallet] = Wallet.wallets
  @Published var walletUrl: URL? = nil
  @Published var account: String? = nil
  
  func connect(wallet: Wallet) {
    let wcUrl =  WCURL(topic: UUID().uuidString,
                       bridgeURL: URL(string: "https://safe-walletconnect.gnosis.io/")!,
                       key: try! randomKey())
    let clientMeta = Session.ClientMeta(name: "Bits Wallet",
                                        description: "Non-custodial Wallet",
                                        icons: [],
                                        url: URL(string: "https://console.so")!)
    let dAppInfo = Session.DAppInfo(peerId: UUID().uuidString, peerMeta: clientMeta)
    client = Client(delegate: self, dAppInfo: dAppInfo)
    
    print("WalletConnect URL: \(wcUrl.absoluteString)")
    
    try? client?.connect(to: wcUrl)
    self.walletUrl = wallet.connectLink(from: wcUrl)
  }
  
  private func randomKey() throws -> String {
    var bytes = [Int8](repeating: 0, count: 32)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    if status == errSecSuccess {
      return Data(bytes: bytes, count: 32).toHexString()
    } else {
      // we don't care in the example app
      enum TestError: Error {
        case unknown
      }
      throw TestError.unknown
    }
  }
}

extension BKSelectWalletViewModel: ClientDelegate {
  func client(_ client: Client, didFailToConnect url: WCURL) {
    print("Failed to connect")
  }
  
  func client(_ client: Client, didConnect url: WCURL) {
    // do nothing
  }
  
  func client(_ client: Client, didConnect session: Session) {
    self.session = session
    let sessionData = try? JSONEncoder().encode(session)
    UserDefaults.standard.set(sessionData, forKey: "sessionKey")
    DispatchQueue.main.async {
      self.account = session.walletInfo?.accounts.first as? String
    }
  }
  
  func client(_ client: Client, didDisconnect session: Session) {
    UserDefaults.standard.removeObject(forKey: "sessionKey")
    print("Did disconnect")
  }
  
  func client(_ client: Client, didUpdate session: Session) {
    // do nothing
  }
}


struct Wallet: Codable, Identifiable {
  let id: String
  let name: String
  let logoUrl: String
  let walletDescription: String
  let homepage: String
  let universal: String
  
  init(id: String = UUID().uuidString, name: String, logoUrl: String, walletDescription: String, homepage: String, universal: String) {
    self.id = id
    self.name = name
    self.logoUrl = logoUrl
    self.walletDescription = walletDescription
    self.homepage = homepage
    self.universal = universal
  }
  
  func connectLink(from url: WCURL) -> URL? {
    guard let universalUrl = URL(string: universal),
          var components = URLComponents(url: universalUrl, resolvingAgainstBaseURL: false),
          let encodedUri = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
      return nil
    }
    components.percentEncodedQuery = "uri=\(encodedUri)"
    if let url = components.url, url.lastPathComponent != "wc" {
      components.path = url.appendingPathComponent("wc").path
    }
    return components.url
  }
}

extension Wallet {
  static let wallets: [Wallet] = [
    Wallet(name: "MetaMask", logoUrl: "https://imagedelivery.net/_aTEfDRm7z3tKgu9JhfeKA/fb5269f0-1870-42d6-82b4-26d27626e800/sm", walletDescription: "", homepage: "https://metamask.io/", universal: "https://metamask.app.link"),
    Wallet(name: "Rainbow", logoUrl: "https://imagedelivery.net/_aTEfDRm7z3tKgu9JhfeKA/2cc2f20c-840b-497a-c028-dbb481d49700/sm", walletDescription: "", homepage: "https://rainbow.me/", universal: "https://rnbwapp.com")
  ]
}

struct BKSelectWalletView: View {
  @Environment(\.openURL) var openURL
  @StateObject private var vm = BKSelectWalletViewModel()
  let didConnect: () -> Void
  
  var body: some View {
    NavigationView {
      ScrollView {
        ForEach(vm.wallets) { wallet in
          WalletButton(wallet: wallet) {
            vm.connect(wallet: wallet)
          }
        }
        .padding()
      }
      .navigationTitle("Select wallet")
    }
    .onChange(of: vm.walletUrl) { url in
      if let url = url {
        openURL(url)
      }
    }
  }
}

struct BKSelectWalletView_Previews: PreviewProvider {
  static var previews: some View {
    BKSelectWalletView(didConnect: {})
  }
}

struct WalletButton: View {
  let wallet: Wallet
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack {
        HStack {
          AsyncImage(url: URL(string: wallet.logoUrl)) { image in
            image
              .resizable()
              .clipShape(Circle())
          } placeholder: {
            Circle()
              .foregroundColor(.gray)
          }
          .aspectRatio(contentMode: .fit)
          .frame(width: 40, height: 40, alignment: .center)
          Text(wallet.name)
            .font(.headline)
            .foregroundColor(.title)
          Spacer()
          Text("Installed")
            .font(.subheadline.weight(.medium))
            .foregroundColor(.subtitle)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .foregroundColor(.neutral1)
        )
      }
    }
  }
}

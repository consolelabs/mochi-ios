//
//  DiscordAuthWebView.swift
//  Mochi Wallet (iOS)
//
//  Created by Oliver Le on 23/11/2022.
//

import SwiftUI
import WebKit

struct DiscordAuthWebView: UIViewRepresentable {
  let url: URL
  @Binding var token: String
  @Binding var error: String
  
  func makeUIView(context: Context) -> some UIView {
    let webView = WKWebView()
    webView.navigationDelegate = context.coordinator
    let request = URLRequest(url: url)
    webView.load(request)
    return webView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
  
  func makeCoordinator() -> DiscordWebViewCoordinator {
    let coordinator = DiscordWebViewCoordinator()
    
    coordinator.didReceiveToken = { token in
      self.token = token
    }
    
    coordinator.receiveTokenFailed = {
      self.error = "User cancel"
    }
    
    return coordinator
  }
}

class DiscordWebViewCoordinator: NSObject, WKNavigationDelegate {
 
  var didStart: () -> Void
  var didFinish: () -> Void
  var didReceiveToken: (String) -> Void
  var receiveTokenFailed: () -> Void
  
  init(didStart: @escaping () -> Void = {},
       didFinish: @escaping () -> Void = {},
       didReceiveToken: @escaping (String) -> Void = { _ in },
       receiveTokenFailed: @escaping () -> Void = {}) {
    self.didStart = didStart
    self.didFinish = didFinish
    self.didReceiveToken = didReceiveToken
    self.receiveTokenFailed = receiveTokenFailed
  }
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    didStart()
    guard let url = webView.url else {
      didReceiveToken("")
      return
    }
     
    if var urlComponent = URLComponents(string: url.absoluteString),
       let host = urlComponent.host, host.hasPrefix("getmochi.co") {
      urlComponent.query = url.fragment
      if let accessToken = urlComponent.queryItems?.first(where: {$0.name == "access_token"})?.value {
        didReceiveToken(accessToken)
      } else {
        receiveTokenFailed()
      }
    }
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    didFinish()
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print(error)
  }
}

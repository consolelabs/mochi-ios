//
//  AboutViewController.swift
//  Mochi Wallet (macOS)
//
//  Created by Oliver Le on 08/11/2022.
//

import Cocoa

class AboutViewController: NSViewController {
  
  @IBOutlet weak var lblVersion: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    lblVersion.stringValue += " \(Bundle.main.releaseVersionNumber ?? "0") (\(Bundle.main.buildVersionNumber ?? "0"))"
  }
}

//
//  HyperlinkTextField.swift
//  Mochi Wallet (macOS)
//
//  Created by Oliver Le on 08/11/2022.
//

import Cocoa

@IBDesignable
class HyperlinkTextField: NSTextField {
    
    @IBInspectable var href: String = ""
    
    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(self.bounds, cursor: NSCursor.pointingHand)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if let localHref = URL(string: href) {
            NSWorkspace.shared.open(localHref)
        }
    }
}


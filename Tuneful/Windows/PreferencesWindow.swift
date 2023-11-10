//
//  PreferencesWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 09/09/2023.
//

import Foundation
import AppKit

class PreferencesWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 240),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.isReleasedWhenClosed = false
    }
}

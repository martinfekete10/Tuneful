//
//  NotificationWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 24/06/2024.
//

import SwiftUI
import AppKit

class NotificationWindow: NSWindow {
    
    init() {
        super.init(
            contentRect: NSRect(x: 10, y: 10, width: 300, height: 145),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isMovableByWindowBackground = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenNone]
        self.isReleasedWhenClosed = false
        self.backgroundColor = NSColor.clear
        self.hasShadow = true
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}


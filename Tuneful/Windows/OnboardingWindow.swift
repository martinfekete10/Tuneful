//
//  OnboardingWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 03/08/2023.
//

import AppKit

class OnboardingWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 200),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenNone]
        self.isMovableByWindowBackground = true
        self.isReleasedWhenClosed = true
        self.level = .floating
        self.backgroundColor = NSColor.clear
        self.hasShadow = true
    }
}

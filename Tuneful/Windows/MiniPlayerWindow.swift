//
//  MainWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 18/08/2023.
//

import AppKit

class MiniPlayerWindow: NSWindow {
    init(width: Int, height: Int) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
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
}

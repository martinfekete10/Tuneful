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
    
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Hide window", action: #selector(hideWindow(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Customize", action: #selector(customize(_:)), keyEquivalent: "")
        
        NSMenu.popUpContextMenu(menu, with: event, for: self.contentView!)
    }
    
    @objc func hideWindow(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayer), to: nil, from: nil)
    }
    
    @objc func customize(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.openMiniPlayerAppearanceSettings), to: nil, from: nil)
    }
}

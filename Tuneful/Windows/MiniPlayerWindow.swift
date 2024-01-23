//
//  MainWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 18/08/2023.
//

import SwiftUI
import AppKit

class MiniPlayerWindow: NSWindow {
    
    @AppStorage("miniPlayerType") var miniPlayerType: MiniPlayerType = .minimal
    
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
    
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Hide window", action: #selector(hideWindow(_:)), keyEquivalent: "")

        let customizeMenuItem = NSMenuItem(title: "Window style", action: nil, keyEquivalent: "")
        let customizeMenu = NSMenu()

        customizeMenu.addItem(withTitle: "Full", action: #selector(setFullPlayer(_:)), keyEquivalent: "")
        customizeMenu.addItem(withTitle: "Minimal", action: #selector(setAlbumArtPlayer(_:)), keyEquivalent: "")

        customizeMenuItem.submenu = customizeMenu
        menu.addItem(customizeMenuItem)
        menu.addItem(withTitle: "Settings...", action: #selector(settings(_:)), keyEquivalent: "")

        NSMenu.popUpContextMenu(menu, with: event, for: self.contentView!)
    }

    @objc func setFullPlayer(_ sender: Any) {
        miniPlayerType = .full
        NSApplication.shared.sendAction(#selector(AppDelegate.setupMiniPlayer), to: nil, from: nil)
    }

    @objc func setAlbumArtPlayer(_ sender: Any) {
        miniPlayerType = .minimal
        NSApplication.shared.sendAction(#selector(AppDelegate.setupMiniPlayer), to: nil, from: nil)
    }

    override var canBecomeKey: Bool {
        return true
    }
    
    @objc func hideWindow(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayer), to: nil, from: nil)
    }
    
    @objc func settings(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.openMiniPlayerAppearanceSettings), to: nil, from: nil)
    }
}

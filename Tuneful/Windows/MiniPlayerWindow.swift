//
//  MainWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 18/08/2023.
//

import SwiftUI
import AppKit
import Defaults

class MiniPlayerWindow: NSWindow {
    init() {
        let position = NSPoint.fromString(Defaults[.windowPosition]) ?? NSPoint(x: 10, y: 10)
        
        super.init(
            contentRect: NSRect(x: position.x, y: position.y, width: 300, height: 145),
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidMove),
            name: NSWindow.didMoveNotification,
            object: self
        )
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Hide window", action: #selector(hideWindow(_:)), keyEquivalent: "")

        let customizeMenuItem = NSMenuItem(title: "Window style", action: nil, keyEquivalent: "")
        let customizeMenu = NSMenu()
        customizeMenu
            .addItem(withTitle: "Full", action: #selector(setFullPlayer(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerType] == .full ? .on : .off
        customizeMenu
            .addItem(withTitle: "Minimal", action: #selector(setAlbumArtPlayer(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerType] == .minimal ? .on : .off
        customizeMenuItem.submenu = customizeMenu
        
        menu.addItem(customizeMenuItem)
        menu.addItem(withTitle: "Settings...", action: #selector(settings(_:)), keyEquivalent: "")

        NSMenu.popUpContextMenu(menu, with: event, for: self.contentView!)
    }
    
    override var canBecomeKey: Bool {
        return true
    }

    @objc func setFullPlayer(_ sender: Any) {
        Defaults[.miniPlayerType] = .full
        NSApplication.shared.sendAction(#selector(AppDelegate.setupMiniPlayer), to: nil, from: nil)
    }

    @objc func setAlbumArtPlayer(_ sender: Any) {
        Defaults[.miniPlayerType] = .minimal
        NSApplication.shared.sendAction(#selector(AppDelegate.setupMiniPlayer), to: nil, from: nil)
    }
    
    @objc func hideWindow(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayer), to: nil, from: nil)
    }
    
    @objc func settings(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.openMiniPlayerAppearanceSettings), to: nil, from: nil)
    }
    
    @objc func windowDidMove(_ notification: Notification) {
        let position = self.frame.origin
        Defaults[.windowPosition] = "\(position.x),\(position.y)"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NSPoint {
    static func fromString(_ string: String) -> NSPoint? {
        let components = string.split(separator: ",")
        guard components.count == 2,
              let x = Double(components[0]),
              let y = Double(components[1]) else {
            return nil
        }
        return NSPoint(x: x, y: y)
    }
}

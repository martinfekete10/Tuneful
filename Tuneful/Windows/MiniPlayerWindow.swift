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
        super.init(
            contentRect: .zero,
            styleMask: [.fullSizeContentView, .borderless, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        
        self.isOpaque = false
        self.isMovableByWindowBackground = true
        self.level = Defaults[.miniPlayerWindowOnTop] ? .floating : .normal
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
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Hide window", action: #selector(hideWindow(_:)), keyEquivalent: "")

        let windowStyleMenuItem = NSMenuItem(title: "Window style", action: nil, keyEquivalent: "")
        let windowMenu = NSMenu()
        windowMenu
            .addItem(withTitle: "Minimal", action: #selector(setCompactMiniPlayer(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerType] == .minimal ? .on : .off
        windowMenu
            .addItem(withTitle: "Horizontal", action: #selector(setHorizontalMiniPlayer(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerType] == .horizontal ? .on : .off
        windowMenu
            .addItem(withTitle: "Vertical", action: #selector(setVerticalMiniPlayer(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerType] == .vertical ? .on : .off
        windowStyleMenuItem.submenu = windowMenu
        menu.addItem(windowStyleMenuItem)
        
        let backgroundStyleMenuItem = NSMenuItem(title: "Background", action: nil, keyEquivalent: "")
        let backgroundMenu = NSMenu()
        backgroundMenu
            .addItem(withTitle: "Tint", action: #selector(setTintBg(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerBackground] == .glow ? .on : .off
        backgroundMenu
            .addItem(withTitle: "Transparent", action: #selector(setTransparentBg(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerBackground] == .transparent ? .on : .off
        backgroundMenu
            .addItem(withTitle: "Album art", action: #selector(setAlbumArtBg(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerBackground] == .albumArt ? .on : .off
        backgroundStyleMenuItem.submenu = backgroundMenu
        menu.addItem(backgroundStyleMenuItem)
        
        let sizeMenuItem = NSMenuItem(title: "Size", action: nil, keyEquivalent: "")
        let sizeMenu = NSMenu()
        sizeMenu
            .addItem(withTitle: "Small", action: #selector(setSmallWindow(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerScaleFactor] == .small ? .on : .off
        sizeMenu
            .addItem(withTitle: "Regular", action: #selector(setRegularWindow(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerScaleFactor] == .regular ? .on : .off
        sizeMenu
            .addItem(withTitle: "Large", action: #selector(setLargeWindow(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerScaleFactor] == .large ? .on : .off
        sizeMenuItem.submenu = sizeMenu
        menu.addItem(sizeMenuItem)
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "Settings...", action: #selector(settings(_:)), keyEquivalent: "")
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "Quit", action: #selector(quit(_:)), keyEquivalent: "")

        NSMenu.popUpContextMenu(menu, with: event, for: self.contentView!)
    }

    @objc func setHorizontalMiniPlayer(_ sender: Any) {
        Defaults[.miniPlayerType] = .horizontal
    }

    @objc func setCompactMiniPlayer(_ sender: Any) {
        Defaults[.miniPlayerType] = .minimal
    }
    
    @objc func setVerticalMiniPlayer(_ sender: Any) {
        Defaults[.miniPlayerType] = .vertical
    }
    
    @objc func setTintBg(_ sender: Any) {
        Defaults[.miniPlayerBackground] = .glow
    }

    @objc func setAlbumArtBg(_ sender: Any) {
        Defaults[.miniPlayerBackground] = .albumArt
    }
    
    @objc func setTransparentBg(_ sender: Any) {
        Defaults[.miniPlayerBackground] = .transparent
    }
    
    @objc func setSmallWindow(_ sender: Any) {
        Defaults[.miniPlayerScaleFactor] = .small
    }

    @objc func setRegularWindow(_ sender: Any) {
        Defaults[.miniPlayerScaleFactor] = .regular
    }
    
    @objc func setLargeWindow(_ sender: Any) {
        Defaults[.miniPlayerScaleFactor] = .large
    }
    
    @objc func hideWindow(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayerAndPlayerMenuItem), to: nil, from: nil)
    }
    
    @objc func settings(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
    }
    
    @objc func quit(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.quit), to: nil, from: nil)
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

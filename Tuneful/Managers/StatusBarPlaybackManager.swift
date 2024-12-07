//
//  StatusBarPlaybackManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 24/02/2024.
//

import SwiftUI
import Defaults

class StatusBarPlaybackManager: ObservableObject {
    private var playerManager: PlayerManager
    private var statusBarItem: NSStatusItem
    
    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
        
        // Playback buttons in meu bar
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusBarItem.isVisible = Defaults[.showMenuBarPlaybackControls]
        self.updateStatusBarPlaybackItem(playerAppIsRunning: playerManager.isRunning)
        
        let contextMenu = NSMenu()
        contextMenu.addItem(
            withTitle: "Settings...",
            action: #selector(AppDelegate.openSettings),
            keyEquivalent: ""
        )
        contextMenu.addItem(
            .separator()
        )
        contextMenu.addItem(
            withTitle: "Quit",
            action: #selector(NSApplication.terminate),
            keyEquivalent: ""
        )
        
        self.statusBarItem.menu = contextMenu
    }

    func toggleStatusBarVisibility() {
        statusBarItem.isVisible = Defaults[.showMenuBarPlaybackControls]
    }
    
    @objc func updateStatusBarPlaybackItem(playerAppIsRunning: Bool) {
        let menuBarView = HStack {
            PlaybackButtonsView(playButtonSize: 12, hideShuffleAndRepeat: true)
                .environmentObject(playerManager)
        }
        
        let iconView = NSHostingView(rootView: menuBarView)
        iconView.frame = NSRect(x: 0, y: 0, width: 90, height: 20)
        
        if let button = self.statusBarItem.button {
            button.subviews.forEach { $0.removeFromSuperview() }
            button.addSubview(iconView)
            button.frame = iconView.frame
        }
    }
}


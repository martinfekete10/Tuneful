//
//  MiniPlayerPreviewHelper.swift
//  Tuneful
//
//  Created by Martin Fekete on 24/12/2024.
//
#if DEBUG
import SwiftUI

struct MiniPlayerPreviewHelper {
    static func setupMiniPlayers(playerManager: PlayerManager) {
        for type in MiniPlayerType.allCases {
            let miniPlayerWindow = MiniPlayerWindow()
            let rootView = MiniPlayerView(miniPlayerType: type).environmentObject(playerManager)
            miniPlayerWindow.contentView = NSHostingView(rootView: rootView)
            
            // This is ugly but we can't correctly set the frame as window is not fully loaded
            // Running this one sec later should ensure we have the window fully loaded -> correctly placed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                miniPlayerWindow.contentView?.layer?.cornerRadius = 12.5
                miniPlayerWindow.contentView?.layer?.masksToBounds = true
                miniPlayerWindow.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
}
#endif

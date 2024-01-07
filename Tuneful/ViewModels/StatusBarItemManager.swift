//
//  MenuBarManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 05/01/2024.
//

import SwiftUI

class StatusBarItemManager: ObservableObject {
    
    @AppStorage("showSongInfo") var showSongInfo: Bool = true
    @AppStorage("trackInfoLength") var trackInfoLength: Double = 20.0
    @AppStorage("statusBarIcon") var statusBarIcon: StatusBarIcon = .appIcon
    @AppStorage("trackInfoDetails") var trackInfoDetails: StatusBarTrackDetails = .artistAndSong
    
    public func getStatusBarTrackInfo(_ notification: NSNotification) -> String {
        guard let trackTitle = notification.userInfo?["title"] as? String else { return "" }
        guard let trackArtist = notification.userInfo?["artist"] as? String else { return "" }
        // 6 spaces are ideal for albumart/icon ("      ")
        let trackInfo = trackTitle.isEmpty && trackArtist.isEmpty ? "" : "      \(trackArtist) • \(trackTitle)".prefix(Int(trackInfoLength))
        
        return String(trackInfo)
    }
    
    public func getIconRootView(albumArt: NSImage) -> AnyView {
        let iconRootView = HStack() {
            switch statusBarIcon {
            case .albumArt:
                Image(nsImage: albumArt)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 18, height: 18)
                    .cornerRadius(4)
            case .appIcon:
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 13, height: 13)
            case .none:
                EmptyView()
            }

        }
        
        return AnyView(iconRootView)
    }
}

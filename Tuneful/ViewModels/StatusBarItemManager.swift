//
//  MenuBarManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 05/01/2024.
//

import SwiftUI

class StatusBarItemManager: ObservableObject {
    
    @AppStorage("showSongInfo") var showSongInfo: Bool = true
    @AppStorage("showMenuBarIcon") var showMenuBarIcon: Bool = false
    @AppStorage("trackInfoLength") var trackInfoLength: Double = 20.0
    @AppStorage("statusBarIcon") var statusBarIcon: StatusBarIcon = .appIcon
    @AppStorage("trackInfoDetails") var trackInfoDetails: StatusBarTrackDetails = .artistAndSong
    
    private var iconWhiteSpaceOffset = "     "
    
    public func getStatusBarTrackInfo(track: Track) -> String {
        if !showSongInfo {
            return "  "
        }
        
        let trackTitle = track.title
        let trackArtist = track.artist
        
        var trackInfo = ""
        if showMenuBarIcon {
            trackInfo = "\(iconWhiteSpaceOffset)"
        }
        switch trackInfoDetails {
        case .artistAndSong:
            trackInfo = "\(trackInfo)\(trackArtist) • \(trackTitle)"
        case .artist:
            trackInfo = "\(trackInfo)\(trackArtist)"
        case .song:
            trackInfo = "\(trackInfo)\(trackTitle)"
        }
        trackInfo = String(trackInfo.prefix(Int(trackInfoLength)))
        
        return trackInfo
    }
    
    public func getIconRootView(albumArt: NSImage) -> AnyView {
        let iconRootView = HStack() {
            if showMenuBarIcon {
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
                }
            } else {
                EmptyView()
            }
        }
        
        return AnyView(iconRootView)
    }
}

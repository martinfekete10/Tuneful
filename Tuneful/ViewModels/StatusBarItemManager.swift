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
    
    // 6 spaces turn out to be ideal for albumart/icon offset
    private var iconWhiteSpaceOffset = "      "
    
    public func getStatusBarTrackInfo(track: Track) -> String {
        let trackTitle = track.title
        let trackArtist = track.artist
        let trackInfo = "\(iconWhiteSpaceOffset)\(trackArtist) • \(trackTitle)".prefix(Int(trackInfoLength))
        
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

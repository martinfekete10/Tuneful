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
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.spotify
    
    public func getStatusBarTrackInfo(track: Track, playerAppIsRunning: Bool) -> String {
        if !showSongInfo {
            return ""
        }
        
        if !playerAppIsRunning {
            return "Open \(connectedApp.rawValue)"
        }
        
        let trackTitle = track.title
        let trackArtist = track.artist
        
        var trackInfo = " "
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
    
    public func getImage(albumArt: NSImage, playerAppIsRunning: Bool) -> NSImage? {
        if !showMenuBarIcon {
            return nil
        }
        
        if statusBarIcon == .albumArt && playerAppIsRunning {
            return albumArt.roundImage(withSize: NSSize(width: 18, height: 18), radius: 4.0)
        }
        
        return NSImage(systemSymbolName: "music.quarternote.3", accessibilityDescription: "Tuneful")
    }
}

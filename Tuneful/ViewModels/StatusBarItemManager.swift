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
    
    public func getStatusBarTrackInfo(track: Track) -> String {
        if !showSongInfo {
            return ""
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
    
    public func getImage(albumArt: NSImage) -> NSImage? {
        if !showMenuBarIcon {
            return nil
        }
        
        switch statusBarIcon {
        case .albumArt:
            return albumArt.roundImage(withSize: NSSize(width: 18, height: 18), radius: 4.0)
        case .appIcon:
            return NSImage(systemSymbolName: "music.quarternote.3", accessibilityDescription: "Tuneful")
        }
    }
}

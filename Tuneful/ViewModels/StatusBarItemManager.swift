//
//  MenuBarManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 05/01/2024.
//

import SwiftUI

class StatusBarItemManager: ObservableObject {
    
    @AppStorage("menuBarItemWidth") var menuBarItemWidth: Double = 150
    @AppStorage("statusBarIcon") var statusBarIcon: StatusBarIcon = .albumArt
    @AppStorage("trackInfoDetails") var trackInfoDetails: StatusBarTrackDetails = .artistAndSong
    @AppStorage("connectedApp") var connectedApp: ConnectedApps = ConnectedApps.spotify
    @AppStorage("showStatusBarTrackInfo") var showStatusBarTrackInfo: ShowStatusBarTrackInfo = .always
    
    public func getMenuBarView(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> NSView {
        let title = self.getStatusBarTrackInfo(track: track, playerAppIsRunning: playerAppIsRunning, isPlaying: isPlaying)
        let image = self.getImage(albumArt: track.albumArt, playerAppIsRunning: playerAppIsRunning)
        
        let titleWidth = title.stringWidth(with: Constants.StatusBar.marqueeFont)
        let menuBarItemWidth = titleWidth == 0 ? Constants.StatusBar.imageWidth : (self.menuBarItemWidth > titleWidth  ? titleWidth : self.menuBarItemWidth)
        
        let mainView = HStack(spacing: 7) {
            if self.statusBarIcon != .hidden || titleWidth == 0 { // Should display icon when there is no menubar text
                Image(nsImage: image)
            }
            
            if titleWidth != 0 {
                MarqueeText(text: title, leftFade: 25.0, rightFade: 5.0, startDelay: 0, animating: isPlaying)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
        let menuBarView = NSHostingView(rootView: mainView)
        menuBarView.frame = NSRect(x: 0, y: 1, width: menuBarItemWidth, height: 20)
        return menuBarView
    }
    
    // MARK: - Private
    
    private func getStatusBarTrackInfo(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> String {
        if self.showStatusBarTrackInfo == .never {
            return ""
        }
        
        if self.showStatusBarTrackInfo == .whenPlaying && !isPlaying {
            return ""
        }
        
        if !playerAppIsRunning {
            return "Open \(connectedApp.rawValue)"
        }
        
        let trackTitle = track.title
        let trackArtist = track.artist
        
        var trackInfo = ""
        switch trackInfoDetails {
        case .artistAndSong:
            // In some cases either of these is missing (e.g. podcasts) which would result in "• PodcastTitle"
            if !trackArtist.isEmpty && !trackTitle.isEmpty {
                trackInfo = "\(trackArtist) • \(trackTitle)"
            } else if !trackArtist.isEmpty {
                trackInfo = "\(trackArtist)"
            } else if !trackTitle.isEmpty {
                trackInfo = "\(trackTitle)"
            }
        case .artist:
            trackInfo = "\(trackArtist)"
        case .song:
            trackInfo = "\(trackTitle)"
        }
        
        return trackInfo
    }
    
    private func getImage(albumArt: NSImage, playerAppIsRunning: Bool) -> NSImage {
        if statusBarIcon == .albumArt && playerAppIsRunning {
            return albumArt.roundImage(withSize: NSSize(width: 18, height: 18), radius: 4.0)
        }
        
        return NSImage(systemSymbolName: "music.quarternote.3", accessibilityDescription: "Tuneful")!
    }
}

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
    @AppStorage("scrollingTrackInfo") var scrollingTrackInfo: Bool = true
    @AppStorage("showEqWhenPlayingMusic") var showEqWhenPlayingMusic: Bool = true
    
    public func getMenuBarView(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> NSView {
        let title = self.getStatusBarTrackInfo(track: track, playerAppIsRunning: playerAppIsRunning, isPlaying: isPlaying)
        let image = self.getImage(albumArt: track.albumArt, playerAppIsRunning: playerAppIsRunning, isPlaying: isPlaying)
        let titleWidth = title.stringWidth(with: Constants.StatusBar.marqueeFont)
        
        var menuBarItemWidth = titleWidth == 0
            ? Constants.StatusBar.imageWidth
            : (self.menuBarItemWidth > titleWidth  ? titleWidth + 5 : self.menuBarItemWidth + 5)
        if self.statusBarIcon != .hidden && titleWidth != 0 {
            menuBarItemWidth += Constants.StatusBar.imageWidth
        }
        
        let mainView = HStack(spacing: 7) {
            if self.statusBarIcon != .hidden || titleWidth == 0 { // Should display icon when there is no menubar text
                image.frame(width: 18, height: 18)
            }
            
            if scrollingTrackInfo && titleWidth != 0 && playerAppIsRunning {
                MarqueeText(text: title, leftFade: 0.0, rightFade: 0.0, startDelay: 0, animating: isPlaying)
            }
            
            if !scrollingTrackInfo && titleWidth != 0 || !playerAppIsRunning {
                Text(title)
                    .lineLimit(1)
                    .font(.system(size: 13, weight: .regular))
                    .offset(x: -2.5) // Prevent small jumps when toggling between scrolling on and off
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
        let menuBarView = NSHostingView(rootView: mainView)
        menuBarView.frame = NSRect(x: 1, y: 1, width: menuBarItemWidth, height: 20)
        return menuBarView
    }
    
    // MARK: - Private
    
    private func getStatusBarTrackInfo(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> String {
        let activePlayback = isPlaying && playerAppIsRunning
        
        if self.showStatusBarTrackInfo == .never {
            return ""
        }
        
        if self.showStatusBarTrackInfo == .whenPlaying && !activePlayback {
            return ""
        }
        
        if !playerAppIsRunning && !activePlayback {
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
    
    private func getImage(albumArt: NSImage, playerAppIsRunning: Bool, isPlaying: Bool) -> AnyView {
        if isPlaying && showEqWhenPlayingMusic && playerAppIsRunning {
            if statusBarIcon == .albumArt {
                return AnyView(
                    Rectangle()
                        .fill(Color(nsColor: albumArt.averageColor ?? .white).gradient)
                        .mask { AudioSpectrumView(isPlaying: isPlaying) }
                )
            } else {
                return AnyView(AudioSpectrumView(isPlaying: isPlaying))
            }
        }
        
        if statusBarIcon == .albumArt && playerAppIsRunning {
            let roundedImage = albumArt.roundImage(withSize: NSSize(width: 18, height: 18), radius: 4.0)
            return AnyView(Image(nsImage: roundedImage))
        }
        
        return AnyView(Image(systemName: "music.quarternote.3"))
    }
}

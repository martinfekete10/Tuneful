//
//  MenuBarManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 05/01/2024.
//

import SwiftUI
import Defaults

class StatusBarItemManager: ObservableObject {
    @ObservedObject var playerManager: PlayerManager
    
    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
    }
    
    public func getMenuBarView(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> NSView {
        let title = self.getStatusBarTrackInfo(track: track, playerAppIsRunning: playerAppIsRunning, isPlaying: isPlaying)
        let image = self.getImage(track: track, playerAppIsRunning: playerAppIsRunning, isPlaying: isPlaying)
        let titleWidth = title.stringWidth(with: Constants.StatusBar.marqueeFont)
        
        var menuBarItemHeigth = 20.0
        var menuBarItemWidth = titleWidth == 0
            ? Constants.StatusBar.imageWidth
            : (Defaults[.menuBarItemWidth] > titleWidth  ? titleWidth + 5 : Defaults[.menuBarItemWidth] + 5)
        if Defaults[.statusBarIcon] != .hidden && titleWidth != 0 {
            menuBarItemWidth += Constants.StatusBar.imageWidth
        }
        
        let mainView = HStack(spacing: 7) {
            if Defaults[.statusBarIcon] != .hidden {
                image.frame(width: 18, height: 18)
            }
            
            if Defaults[.scrollingTrackInfo] && titleWidth != 0 && playerAppIsRunning {
                MarqueeText(text: title, leftFade: 0.0, rightFade: 0.0, startDelay: 0, animating: isPlaying)
            }
            
            if !Defaults[.scrollingTrackInfo] && titleWidth != 0 || !playerAppIsRunning {
                Text(title)
                    .lineLimit(1)
                    .font(.system(size: 13, weight: .regular))
                    .offset(x: -2.5) // Prevent small jumps when toggling between scrolling on and off
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
        if Defaults[.statusBarIcon] == .hidden && titleWidth == 0 {
            menuBarItemHeigth = 0
            menuBarItemWidth = 0
       }
        
        let menuBarView = NSHostingView(rootView: mainView)
        menuBarView.frame = NSRect(x: 1, y: 1, width: menuBarItemWidth, height: menuBarItemHeigth)
        return menuBarView
    }
    
    // MARK: Private
    
    private func getStatusBarTrackInfo(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> String {
        let activePlayback = isPlaying && playerAppIsRunning
        
        if Defaults[.showStatusBarTrackInfo] == .never {
            return ""
        }
        
        if Defaults[.showStatusBarTrackInfo] == .whenPlaying && !activePlayback {
            return ""
        }
        
        if track.isEmpty() {
            return ""
        }
        
        if !playerAppIsRunning && !activePlayback {
            return "Open \(Defaults[.connectedApp].rawValue)"
        }
        
        return getTrackInfoDetails(track: track)
    }
    
    private func getTrackInfoDetails(track: Track) -> String {
        var title = track.title
        var album = track.album
        var artist = track.artist
        
        // In pocasts, replace artist name with podcast name (as artist name is empty)
        if artist.isEmpty { artist = album }
        if album.isEmpty { album = artist }
        if title.isEmpty { title = album }
        
        var trackInfo = ""
        switch Defaults[.trackInfoDetails] {
        case .artistAndSong:
            trackInfo = "\(artist) • \(title)"
        case .artist:
            trackInfo = "\(artist)"
        case .song:
            trackInfo = "\(title)"
        }
        
        return trackInfo
    }
    
    private func getImage(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> AnyView {
        if isPlaying && Defaults[.showEqWhenPlayingMusic] && playerAppIsRunning {
            if Defaults[.statusBarIcon] == .albumArt {
                return AnyView(
                    Rectangle()
                        .fill(Color(nsColor: track.nsAlbumArt.averageColor ?? .white).gradient)
                        .mask { AudioSpectrumView().environmentObject(playerManager) }
                )
            } else {
                return AnyView(AudioSpectrumView().environmentObject(playerManager))
            }
        }
        
        if Defaults[.statusBarIcon] == .albumArt && playerAppIsRunning {
            return AnyView(track.albumArt.resizable().frame(width: 18, height: 18).cornerRadius(4))
        }
        
        return AnyView(Image(systemName: "music.quarternote.3"))
    }
}

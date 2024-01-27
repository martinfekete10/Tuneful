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
    @AppStorage("showMenuBarControls") var showMenuBarControls: Bool = true
    
    private var playerManager: PlayerManager
    private var statusBarItem: NSStatusItem
    
    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        self.updateStatusBarVisibility()
        self.updateStatusBarItem()
    }
    
    private func updateStatusBarVisibility() {
        statusBarItem.isVisible = self.showMenuBarControls
    }

    func toggleStatusBarVisibility() {
        self.showMenuBarControls.toggle()
        updateStatusBarVisibility()
    }
    
    @objc func updateStatusBarItem() {
        let menuBarView = HStack {
            Button(action: playerManager.previousTrack){
                Image(systemName: "backward.end.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .animation(.easeInOut(duration: 2.0), value: 1)
            }
            .pressButtonStyle()
            
            PlayPauseButton(buttonSize: 15)
                .environmentObject(playerManager)
            
            Button(action: playerManager.nextTrack) {
                Image(systemName: "forward.end.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .animation(.easeInOut(duration: 2.0), value: 1)
            }
            .pressButtonStyle()
        }
        .frame(width: 70, height: 22)
        .background(
            Color.primary.opacity(0.2),
            in: RoundedRectangle(cornerRadius: 5)
        )
        
        let iconView = NSHostingView(rootView: menuBarView)
        iconView.frame = NSRect(x: 0, y: 1, width: 70, height: 20)
        
        if let button = self.statusBarItem.button {
            button.subviews.forEach { $0.removeFromSuperview() }
            button.addSubview(iconView)
            button.frame = iconView.frame
        }
    }
    
    public func getMenuBarView(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> NSView {
        let title = self.getStatusBarTrackInfo(track: track, playerAppIsRunning: playerAppIsRunning, isPlaying: isPlaying)
        let image = self.getImage(albumArt: track.albumArt, playerAppIsRunning: playerAppIsRunning)
        
        let menuBarItemWidth = title == "" ? Constants.StatusBar.imageWidth : self.menuBarItemWidth
        let isItemBiggerThanLimit = Constants.StatusBar.imageWidth + title.stringWidth(with: Constants.StatusBar.marqueeFont) >= menuBarItemWidth
        let xOffset = isItemBiggerThanLimit ? 10 : (self.menuBarItemWidth - Constants.StatusBar.imageWidth - title.stringWidth(with: Constants.StatusBar.marqueeFont)) / 2
        
        let menuBarIconView = 
        VStack(alignment: .center) {
            ZStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Image(nsImage: image)
                    MarqueeText(text: title, leftFade: 10.0, rightFade: 10.0, startDelay: 0, animating: isPlaying)
                }
            }
        }
        
        let iconView = NSHostingView(rootView: menuBarIconView)
        iconView.frame = NSRect(x: xOffset, y: 1, width: menuBarItemWidth, height: 20)
        
        return iconView
    }
    
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

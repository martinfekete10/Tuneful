//
//  AppleMusicManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 03/10/2024.
//

import os
import Combine
import Foundation
import AppKit
import ScriptingBridge

class AppleMusicManager: PlayerProtocol {
    var app: MusicApplication = SBApplication(bundleIdentifier: Constants.AppleMusic.bundleID)!
    var notificationSubject: PassthroughSubject<AlertItem, Never>
    
    public var appName: String { "Apple Music" }
    public var appPath: URL = URL(fileURLWithPath: "/Applications/Music.app")
    public var appNotification: String { "\(Constants.AppleMusic.bundleID).playerInfo" }
    
    public var playerPosition: Double? { app.playerPosition }
    public var isPlaying: Bool { app.playerState == .playing }
    public var isRunning: Bool { app.isRunning }
    public var volume: CGFloat { CGFloat(app.soundVolume ?? 50) }
    public var isLikeAuthorized: Bool = true
    public var shuffleIsOn: Bool { app.shuffleEnabled ?? false }
    public var shuffleContextEnabled: Bool = true
    public var repeatContextEnabled: Bool = true
    
    init(notificationSubject: PassthroughSubject<AlertItem, Never>) {
        self.notificationSubject = notificationSubject
    }
    
    func refreshInfo(completion: @escaping () -> Void) {
        DispatchQueue.main.async() {
            completion()
        }
    }
    
    func getAlbumArt(completion: @escaping (NSImage?) -> Void) {
        guard let art = app.currentTrack?.artworks?()[0] as? MusicArtwork else {
            completion(nil)
            return
        }
        
        if let data = art.data, !data.isEmpty() {
            completion(data)
        } else {
            completion(nil)
            return
        }
    }
    
    func getTrackInfo() -> Track {
        var track = Track()
        track.title = app.currentTrack?.name ?? "Unknown Title"
        track.artist = app.currentTrack?.artist ?? "Unknown Artist"
        track.album = app.currentTrack?.album ?? "Unknown Artist"
        track.duration = CGFloat(app.currentTrack?.duration ?? 0)
        return track
    }
    
    func playPause() {
        app.playpause?()
    }
    
    func previousTrack() {
        app.previousTrack?()
    }
    
    func nextTrack() {
        app.nextTrack?()
    }
    
    func toggleLoveTrack() -> Bool {
        // Different versions of Apple Music use different names for starring tracks
        if let isLovedTrack = app.currentTrack?.loved {
            app.currentTrack?.setLoved?(!isLovedTrack)
            return !isLovedTrack
        } else if let isLovedTrack = app.currentTrack?.favorited {
            app.currentTrack?.setFavorited?(!isLovedTrack)
            return !isLovedTrack
        } else {
            self.sendNotification(title: "Error", message: "Could not save track to favorites")
            return false
        }
    }
    
    func setShuffle(shuffleIsOn: Bool) -> Bool {
        app.setShuffleEnabled?(!shuffleIsOn)
        return !shuffleIsOn
    }
    
    func setRepeat(repeatIsOn: Bool) -> Bool {
        var musicErpt: MusicERpt
        if !repeatIsOn {
            musicErpt = .all
        } else {
            musicErpt = .off
        }
        app.setSongRepeat?(musicErpt)
        
        return !repeatIsOn
    }
    
    func getCurrentSeekerPosition() -> Double {
        return Double(app.playerPosition ?? 0)
    }
    
    func seekTrack(seekerPosition: CGFloat) {
        app.setPlayerPosition?(seekerPosition)
    }
    
    func setVolume(volume: Int) {
        app.setSoundVolume?(volume)
    }
}

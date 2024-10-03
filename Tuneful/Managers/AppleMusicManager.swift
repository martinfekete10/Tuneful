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

class AppleMusicManager: PlayerProtocol {
    var app: MusicApplication
    var notificationSubject: PassthroughSubject<AlertItem, Never>
    
    public var playerPosition: Double? { app.playerPosition }
    public var duration: CGFloat { CGFloat(app.currentTrack?.duration ?? 1) }
    public var volume: CGFloat { CGFloat(app.soundVolume ?? 50) }
    public var appPath: URL = URL(fileURLWithPath: "/System/Applications/Music.app")
    public var isLikeAuthorized: Bool = true
    public var shuffleIsOn: Bool { app.shuffleEnabled ?? false }
    public var shuffleContextEnabled: Bool = true
    public var repeatContextEnabled: Bool = true
    
    init(app: MusicApplication, notificationSubject: PassthroughSubject<AlertItem, Never>) {
        self.app = app
        self.notificationSubject = notificationSubject
    }
    
    func getAlbumArt(completion: @escaping (NSImage?) -> Void) {
        var count = 0
        
        func waitForData() {
            guard let art = app.currentTrack?.artworks?()[0] as? MusicArtwork else {
                completion(nil)
                return
            }
            
            if let data = art.data, !data.isEmpty() {
                completion(data)
            } else {
                if count > 20 {
                    completion(nil)
                    return
                }
                count += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    waitForData()
                }
            }
        }
        
        waitForData()
    }

    
    func getTrackInfo() -> Track {
        var track = Track()
        track.title = app.currentTrack?.name ?? "Unknown Title"
        track.artist = app.currentTrack?.artist ?? "Unknown Artist"
        track.album = app.currentTrack?.album ?? "Unknown Artist"
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

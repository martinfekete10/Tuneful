//
//  SpotifyManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 03/10/2024.
//

import os
import Combine
import Foundation
import AppKit
import ScriptingBridge

class SpotifyManager: PlayerProtocol {
    var app: SpotifyApplication = SBApplication(bundleIdentifier: Constants.Spotify.bundleID)!
    var notificationSubject: PassthroughSubject<AlertItem, Never>
    
    public var bundleId: String { "com.spotify.client" }
    public var appName: String { "Spotify" }
    public var appPath: URL = URL(fileURLWithPath: "/Applications/Spotify.app")
    public var appNotification: String { "\(Constants.Spotify.bundleID).PlaybackStateChanged" }
    
    public var playerPosition: Double? { app.playerPosition }
    public var isPlaying: Bool { app.playerState == .playing }
    public var isRunning: Bool { app.isRunning }
    public var duration: CGFloat { CGFloat(app.currentTrack?.duration ?? 1) / 1000 }
    public var volume: CGFloat { CGFloat(app.soundVolume ?? 50) }
    public var isLikeAuthorized: Bool = false
    public var shuffleIsOn: Bool { app.shuffling ?? false }
    public var shuffleContextEnabled: Bool { app.shufflingEnabled ?? false }
    public var repeatContextEnabled: Bool { app.repeatingEnabled ?? false }
    
    init(notificationSubject: PassthroughSubject<AlertItem, Never>) {
        self.notificationSubject = notificationSubject
    }
    
    func getTrackInfo() -> Track {
        var track = Track()
        track.title = app.currentTrack?.name ?? "Unknown Title"
        track.artist = app.currentTrack?.artist ?? "Unknown Artist"
        track.album = app.currentTrack?.album ?? "Unknown Artist"
        return track
    }
    
    func getTrackInfoAsync(completion: @escaping (Track?) -> Void) {
        DispatchQueue.global().async {
            var track = Track()
            track.title = self.app.currentTrack?.name ?? "Unknown Title"
            track.artist = self.app.currentTrack?.artist ?? "Unknown Artist"
            track.album = self.app.currentTrack?.album ?? "Unknown Artist"
            
            DispatchQueue.main.async {
                completion(track)
            }
        }
    }
    
    func getAlbumArt(completion: @escaping (NSImage?) -> Void) {
        let urlString = app.currentTrack?.artworkUrl
        
        guard urlString != nil else {
            completion(nil)
            return
        }
        
        guard let url = URL(string: urlString!) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data, let image = NSImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
            
        }.resume()
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
        sendNotification(title: "Error", message: "Adding songs to favorites is not supported for Spotify")
        return false
    }
    
    func setShuffle(shuffleIsOn: Bool) -> Bool {
        app.setShuffling?(!shuffleIsOn)
        return !shuffleIsOn
    }
    
    func setRepeat(repeatIsOn: Bool) -> Bool {
        app.setRepeating?(!repeatIsOn)
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

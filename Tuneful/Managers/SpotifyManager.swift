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

class SpotifyManager: PlayerProtocol {
    var app: SpotifyApplication
    var notificationSubject: PassthroughSubject<AlertItem, Never>
    
    public var playerPosition: Double? { app.playerPosition }
    public var duration: CGFloat { CGFloat(app.currentTrack?.duration ?? 1) / 1000 }
    public var volume: CGFloat { CGFloat(app.soundVolume ?? 50) }
    public var appPath: URL = URL(fileURLWithPath: "/Applications/Spotify.app")
    public var isLikeAuthorized: Bool = false
    public var shuffleIsOn: Bool { app.shuffling ?? false }
    public var shuffleContextEnabled: Bool { app.shufflingEnabled ?? false }
    public var repeatContextEnabled: Bool { app.repeatingEnabled ?? false }
    
    init(app: SpotifyApplication, notificationSubject: PassthroughSubject<AlertItem, Never>) {
        self.app = app
        self.notificationSubject = notificationSubject
    }
    
    func getTrackInfo() -> Track {
        var track = Track()
        track.title = app.currentTrack?.name ?? "Unknown Title"
        track.artist = app.currentTrack?.artist ?? "Unknown Artist"
        track.album = app.currentTrack?.album ?? "Unknown Artist"
        return track
    }
    
    func getAlbumArt(completion: @escaping (NSImage?) -> Void) {
        let urlString = app.currentTrack?.artworkUrl
        
        guard urlString != nil else {
            Logger.main.log("No album art URL string")
            completion(nil)
            return
        }
        
        guard let url = URL(string: urlString!) else {
            Logger.main.log("Invalid album art URL string")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                Logger.main.log("Failed to fetch artwork: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data, let image = NSImage(data: data) else {
                Logger.main.log("No data or image could not be created")
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

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
import SwiftUI
import ScriptingBridge

class SpotifyManager: PlayerProtocol {
    var app: SpotifyApplication = SBApplication(bundleIdentifier: Constants.Spotify.bundleID)!
    var notificationSubject: PassthroughSubject<AlertItem, Never>
    
    public var bundleId: String { Constants.Spotify.bundleID }
    public var appName: String { "Spotify" }
    public var appPath: URL = URL(fileURLWithPath: "/Applications/Spotify.app")
    public var appNotification: String { "\(bundleId).PlaybackStateChanged" }
    public var defaultAlbumArt: NSImage { AppIcons().getIcon(bundleID: bundleId) ?? NSImage() }
    
    public var playerPosition: Double? { app.playerPosition }
    public var isPlaying: Bool { app.playerState == .playing }
    public var volume: CGFloat { CGFloat(app.soundVolume ?? 50) }
    public var isLikeAuthorized: Bool = false
    public var shuffleIsOn: Bool { app.shuffling ?? false }
    public var shuffleContextEnabled: Bool { app.shufflingEnabled ?? false }
    public var repeatContextEnabled: Bool { app.repeatingEnabled ?? false }
    public var playbackSeekerEnabled: Bool { true }
    
    init(notificationSubject: PassthroughSubject<AlertItem, Never>) {
        self.notificationSubject = notificationSubject
    }
    
    func refreshInfo(completion: @escaping () -> Void) {
        DispatchQueue.main.async() {
            completion()
        }
    }
    
    func getTrackInfo() -> Track {
        var track = Track()
        track.title = app.currentTrack?.name ?? "Unknown Title"
        track.artist = app.currentTrack?.artist ?? "Unknown Artist"
        track.album = app.currentTrack?.album ?? "Unknown Artist"
        track.duration = CGFloat(app.currentTrack?.duration ?? 0) / 1000
        return track
    }
    
    func getAlbumArt(completion: @escaping (FetchedAlbumArt?) -> Void) {
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
            guard error == nil, let data = data, let image = NSImage(data: data) else {
                Logger.main.log("Error fetching Spotify album image")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                Logger.main.log("Spotify album image fetched")
                completion(FetchedAlbumArt(image: Image(nsImage: image), nsImage: image))
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
    
    func isRunning() -> Bool {
        let workspace = NSWorkspace.shared
        
        return workspace.runningApplications.contains { app in
            app.bundleIdentifier == self.bundleId
        }
    }
}

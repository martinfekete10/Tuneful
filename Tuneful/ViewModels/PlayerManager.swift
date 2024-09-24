//
//  PlayerManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 29/07/2023.
//

import Combine
import Foundation
import SwiftUI
import ScriptingBridge
import ISSoundAdditions
import os

class PlayerManager: ObservableObject {
    
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.spotify
    @AppStorage("showPlayerWindow") private var showPlayerWindow: Bool = true
    
    var spotifyApp: SpotifyApplication?
    var appleMusicApp: MusicApplication?
    
    var name: String {
        connectedApp == .spotify ? Constants.Spotify.name : Constants.AppleMusic.name
    }
    
    var isRunning: Bool {
        connectedApp == .spotify ? spotifyApp?.isRunning ?? false : appleMusicApp?.isRunning ?? false
    }
    
    var notification: String {
        connectedApp == .spotify ? Constants.Spotify.notification : Constants.AppleMusic.notification
    }
    
    // Notifications
    let notificationSubject = PassthroughSubject<AlertItem, Never>()
    
    // Track
    @Published var track = Track()
    @Published var isPlaying = false
    @Published var isLoved = false
    
    // Seeker
    @Published var trackDuration: Double = 0
    @Published var seekerPosition: CGFloat = 0 {
        didSet {
            self.updateFormattedPlaybackPosition()
        }
    }
    @Published var isDraggingPlaybackPositionView = false {
        didSet {
            self.draggingPlaybackPosition()
        }
    }
    
    // Popover
    @Published var popoverIsShown = false
    
    // Playback
    @Published var shuffleIsOn = false
    @Published var shuffleContextEnabled = false
    @Published var repeatIsOn = false
    @Published var repeatContextEnabled = false
  
    // Playback time
    static let noPlaybackPositionPlaceholder = "- : -"
    var formattedDuration = PlayerManager.noPlaybackPositionPlaceholder
    var formattedPlaybackPosition = PlayerManager.noPlaybackPositionPlaceholder
    
    // Volume
    @Published var volume: CGFloat = 50.0
    @Published var isDraggingSoundVolumeSlider = false
    
    // Audio devices
    @Published var audioDevices = AudioDevice.output.filter{ $0.transportType != .virtual }
    
    // Observer
    private var observer: NSKeyValueObservation?
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    private var currentUserSavedTracksContainsCancellable: AnyCancellable? = nil
    private var requestTokensCancellable: AnyCancellable? = nil
    private var updatePlayerStateCancellable: AnyCancellable? = nil
    
    // Emits when the popover is shown or closed
    let timerStartSignal = PassthroughSubject<Void, Never>()
    let timerStopSignal = PassthroughSubject<Void, Never>()
    
    init() {
        // Music app and observers
        self.setupMusicApps()
        self.setupObservers()
        
        self.playStateOrTrackDidChange(nil)
        
        // Updating player state every 1 sec
        self.timerStartSignal.sink {
            self.getCurrentSeekerPosition()
            self.updatePlayerStateCancellable = Timer.publish(
                every: 1, on: .main, in: .common
            )
            .autoconnect()
            .sink { _ in
                self.getVolume()
                self.getCurrentSeekerPosition()
            }
        }
        .store(in: &self.cancellables)
        
        self.timerStopSignal.sink {
            self.updatePlayerStateCancellable = nil
        }
        .store(in: &self.cancellables)
    }
    
    deinit {
        observer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupMusicApps() {
        Logger.main.log("PlayerManager.setupMusicApps")
        
        switch connectedApp {
        case .spotify:
            guard spotifyApp == nil else { return }
            spotifyApp = SBApplication(bundleIdentifier: Constants.Spotify.bundleID)
        case .appleMusic:
            guard appleMusicApp == nil else { return }
            appleMusicApp = SBApplication(bundleIdentifier: Constants.AppleMusic.bundleID)
        }
    }
    
    public func setupObservers() {
        Logger.main.log("PlayerManager.setupObservers")
        
        observer = UserDefaults.standard.observe(\.connectedApp, options: [.old, .new]) { defaults, change in
            DistributedNotificationCenter.default().removeObserver(self)
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(self.playStateOrTrackDidChange),
                name: NSNotification.Name(rawValue: self.notification),
                object: nil,
                suspensionBehavior: .deliverImmediately
            )
             
            self.setupMusicApps()
            self.playStateOrTrackDidChange(nil)
        }
                
        // ScriptingBridge Observer
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(playStateOrTrackDidChange),
            name: NSNotification.Name(rawValue: notification),
            object: nil,
            suspensionBehavior: .deliverImmediately
        )
        
        // Add observer to listen for popover open
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(popoverIsOpening),
            name: NSPopover.willShowNotification,
            object: nil
        )

        // Add observer to listen for popover close
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(popoverIsClosing),
            name: NSPopover.didCloseNotification,
            object: nil
        )
    }

    @objc private func popoverIsOpening(_ notification: NSNotification) {
        Logger.main.log("PlayerManager.popoverIsOpening")
        
        if !showPlayerWindow {
            self.timerStartSignal.send()
        }
        self.audioDevices = AudioDevice.output.filter{ $0.transportType != .virtual }
        self.getVolume()
        popoverIsShown = true
    }

    @objc private func popoverIsClosing(_ notification: NSNotification) {
        Logger.main.log("PlayerManager.popoverIsClosing")
        
        if !showPlayerWindow {
            self.timerStopSignal.send()
        }
        popoverIsShown = false
    }
    
    // MARK: - Notification Handlers
    
    @objc func musicAppChanged(_ sender: NSNotification?) {
        Logger.main.log("PlayerManager.musicAppChanged")
        
        self.setupMusicApps()
        guard isRunning, sender?.userInfo?["Player State"] as? String != "Stopped" else {
            self.track.title = ""
            self.track.artist = ""
            self.track.albumArt = NSImage()
            self.trackDuration = 0
            return
        }
        
        self.getPlayState()
        self.updatePlayerState()
        self.updateFormattedDuration()
    }
    
    @objc func playStateOrTrackDidChange(_ sender: NSNotification?) {
        Logger.main.log("PlayerManager.playStateOrTrackDidChange")
        
        let musicAppKilled = sender?.userInfo?["Player State"] as? String == "Stopped"
        let isRunningFromNotification = !musicAppKilled && isRunning
    
        guard isRunningFromNotification else {
            self.track.title = ""
            self.track.artist = ""
            self.track.albumArt = NSImage()
            self.trackDuration = 0
            self.updateMenuBarText(playerAppIsRunning: isRunningFromNotification)
            return
        }
        
        self.getPlayState()
        self.updatePlayerState()
        self.updateFormattedDuration()
        self.updateMenuBarText(playerAppIsRunning: isRunningFromNotification)
    }
    
    private func updateMenuBarText(playerAppIsRunning: Bool) {
        Logger.main.log("PlayerManager.updateMenuBarText")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateMenuBarItem"), object: nil, userInfo: ["PlayerAppIsRunning": playerAppIsRunning])
        }
    }
    
    // MARK: - Media & Playback
    
    private func playStateChanged() -> Bool {
        Logger.main.log("PlayerManager.playStateChanged")
        
        switch connectedApp {
        case .spotify:
            if (isPlaying && spotifyApp?.playerState == .playing) || (!isPlaying && spotifyApp?.playerState != .playing) {
                return false
            }
        case .appleMusic:
            if (isPlaying && appleMusicApp?.playerState == .playing) || (!isPlaying && appleMusicApp?.playerState != .playing) {
                return false
            }
        }
        
        return true
    }
    
    private func getPlayState() {
        Logger.main.log("PlayerManager.getPlayState")
        
        isPlaying = connectedApp == .spotify
        ? spotifyApp?.playerState == .playing
        : appleMusicApp?.playerState == .playing
    }
    
    private func sendNotification(title: String, message: String) {
        let alertTitle = NSLocalizedString(
            title,
            comment: ""
        )
        let alert = AlertItem(
            title: alertTitle,
            message: message
        )
        self.notificationSubject.send(alert)
    }
    
    func updatePlayerState() {
        Logger.main.log("PlayerManager.updatePlayerState")
        
        switch connectedApp {
        case .spotify:
            
            // Track
            self.track.title = spotifyApp?.currentTrack?.name ?? "Unknown Title"
            self.track.artist = spotifyApp?.currentTrack?.artist ?? "Unknown Artist"
            self.track.album = spotifyApp?.currentTrack?.album ?? "Unknown Album"
            
            // Playback
            self.shuffleIsOn = spotifyApp?.shuffling ?? false
            self.shuffleContextEnabled = spotifyApp?.shufflingEnabled ?? false
            self.repeatContextEnabled = spotifyApp?.repeatingEnabled ?? false
            
            if let artworkURLString = spotifyApp?.currentTrack?.artworkUrl,
               let url = URL(string: artworkURLString) {
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    guard let data = data, error == nil else {
                        Logger.main.log("PlayerManager.updatePlayerState: couldn't retrieve playback state")
                        self?.sendNotification(title: "Couldn't Retrieve Playback State", message: error!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        self?.track.albumArt = NSImage(data: data) ?? NSImage()
                        self?.updateMenuBarText(playerAppIsRunning: self!.isRunning)
                    }
                    
                }.resume()
            }
            
            // Seeker
            self.trackDuration = Double(spotifyApp?.currentTrack?.duration ?? 1) / 1000
            
        case .appleMusic:
            
            // Track
            self.track.title = appleMusicApp?.currentTrack?.name ?? "Unknown Title"
            self.track.artist = appleMusicApp?.currentTrack?.artist ?? "Unknown Artist"
            self.track.album = appleMusicApp?.currentTrack?.album ?? "Unknown Album"
            self.isLoved = appleMusicApp?.currentTrack?.favorited ?? false
            
            // Playback
            self.shuffleIsOn = appleMusicApp?.shuffleEnabled ?? false
            self.shuffleContextEnabled = true // Always can shuffle in Apple Music
            self.repeatContextEnabled = true // Always can repeat in Apple Music
            
            // Might have to change this later...
            var count = 0
            var waitForData: (() -> Void)!
            waitForData = {
                let art = self.appleMusicApp?.currentTrack?.artworks?()[0] as! MusicArtwork
                if art.data != nil && !art.data!.isEmpty() {
                    self.track.albumArt = art.data!
                } else {
                    if count > 20 { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        waitForData()
                    }
                }
                count += 1
            }
            waitForData()
            
            // Seeker
            self.trackDuration = Double(appleMusicApp?.currentTrack?.duration ?? 1)
        }
        
        self.getCurrentSeekerPosition()
    }
    
    // MARK: - Controls
    
    func togglePlayPause() {
        Logger.main.log("PlayerManager.togglePlayPause")
        
        switch connectedApp {
        case .spotify:
            spotifyApp?.playpause?()
        case .appleMusic:
            appleMusicApp?.playpause?()
        }
    }
    
    func previousTrack() {
        Logger.main.log("PlayerManager.previousTrack")
        
        switch connectedApp {
        case .spotify:
            spotifyApp?.previousTrack?()
        case .appleMusic:
            appleMusicApp?.backTrack?()
        }
    }
    
    func nextTrack() {
        Logger.main.log("PlayerManager.nextTrack")
        
        switch connectedApp {
        case .spotify:
            spotifyApp?.nextTrack?()
        case .appleMusic:
            appleMusicApp?.nextTrack?()
        }
    }
    
    func toggleLoveTrack() {
        Logger.main.log("PlayerManager.toggleLoveTrack")
        
        switch connectedApp {
        case .appleMusic:
            self.toggleAppleMusicLove()
        case .spotify:
            self.sendNotification(title: "Error", message: "Adding songs to favorites is not supported for Spotify yet")
        }
    }
    
    func toggleAppleMusicLove() {
        Logger.main.log("PlayerManager.toggleAppleMusicLove")
        
        // Different versions of Apple Music use different names for starring tracks
        if let isLovedTrack = appleMusicApp?.currentTrack?.loved {
            appleMusicApp?.currentTrack?.setLoved?(!isLovedTrack)
            self.isLoved = !isLovedTrack
        } else if let isLovedTrack = appleMusicApp?.currentTrack?.favorited {
            appleMusicApp?.currentTrack?.setFavorited?(!isLovedTrack)
            self.isLoved = !isLovedTrack
        } else {
            self.sendNotification(title: "Error", message: "Could not save track to favorites")
        }
    }
    
    func setShuffle() {
        Logger.main.log("PlayerManager.setShuffle")
        
        self.shuffleIsOn.toggle()
        switch connectedApp {
        case .appleMusic:
            self.appleMusicApp?.setShuffleEnabled?(self.shuffleIsOn)
        case .spotify:
            self.spotifyApp?.setShuffling?(self.shuffleIsOn)
        }
    }
    
    func setRepeat() {
        Logger.main.log("PlayerManager.setRepeat")
        
        self.repeatIsOn.toggle()
        switch connectedApp {
        case .appleMusic:
            var musicErpt: MusicERpt
            if repeatIsOn {
                musicErpt = .all
            } else {
                musicErpt = .off
            }
            self.appleMusicApp?.setSongRepeat?(musicErpt)
        case .spotify:
            self.spotifyApp?.setRepeating?(repeatIsOn)
        }
    }
    
    // MARK: - Seeker
    
    func getCurrentSeekerPosition() {
        Logger.main.log("PlayerManager.getCurrentSeekerPosition")
        
        guard isRunning else { return }
        if isDraggingPlaybackPositionView { return }
        
        self.seekerPosition = connectedApp == .spotify
        ? Double(spotifyApp?.playerPosition ?? 0)
        : Double(appleMusicApp?.playerPosition ?? 0)
    }
    
    func seekTrack() {
        Logger.main.log("PlayerManager.seekTrack")
        
        switch connectedApp {
        case .appleMusic:
            appleMusicApp?.setPlayerPosition?(seekerPosition)
        case .spotify:
            spotifyApp?.setPlayerPosition?(seekerPosition)
        }
    }
    
    func updateFormattedPlaybackPosition() {
        Logger.main.log("PlayerManager.updateFormattedPlaybackPosition")
        
        switch connectedApp {
        case .spotify:
            if self.spotifyApp?.playerPosition == nil {
                self.formattedPlaybackPosition = Self.noPlaybackPositionPlaceholder
                return
            }
        case .appleMusic:
            if self.appleMusicApp?.playerPosition == nil {
                self.formattedPlaybackPosition = Self.noPlaybackPositionPlaceholder
                return
            }
        }
        
        if self.isDraggingPlaybackPositionView {
            return
        }
        
        self.formattedPlaybackPosition = self.formattedTimestamp(self.seekerPosition)
    }
    
    func updateFormattedDuration() {
        Logger.main.log("PlayerManager.updateFormattedDuration")
        
        var durationSeconds: CGFloat
        switch connectedApp {
        case .spotify:
            if spotifyApp?.currentTrack?.duration == nil {
                self.formattedDuration = Self.noPlaybackPositionPlaceholder
            }
            durationSeconds = CGFloat(
                (self.spotifyApp?.currentTrack?.duration ?? 1) / 1000
            )
        case .appleMusic:
            if appleMusicApp?.currentTrack?.duration == nil {
                self.formattedDuration = Self.noPlaybackPositionPlaceholder
            }
            durationSeconds = CGFloat(
                self.appleMusicApp?.currentTrack?.duration ?? 1
            )
        }
        
        self.formattedDuration = self.formattedTimestamp(durationSeconds)
    }
    
    func draggingPlaybackPosition() {
        self.formattedPlaybackPosition = self.formattedTimestamp(
            self.seekerPosition
        )
    }
    
    // MARK: - Volume
    
    func getVolume() {
        Logger.main.log("PlayerManager.getVolume")
        
        switch connectedApp {
        case .spotify:
            self.volume = CGFloat(spotifyApp?.soundVolume ?? 50)
        case .appleMusic:
            self.volume = CGFloat(appleMusicApp?.soundVolume ?? 50)
        }
    }
    
    func setVolume(newVolume: Int) {
        Logger.main.log("PlayerManager.setVolume")
        
        var newVolume = newVolume
        if newVolume > 100 { newVolume = 100 }
        if newVolume < 0 { newVolume = 0 }
        
        switch connectedApp {
        case .spotify:
            self.spotifyApp?.setSoundVolume?(newVolume)
        case .appleMusic:
            self.appleMusicApp?.setSoundVolume?(newVolume)
        }

        self.volume = CGFloat(newVolume)
    }
    
    func increaseVolume() {
        Logger.main.log("PlayerManager.increaseVolume")
        
        let newVolume = Int(self.volume) + 10
        
        self.setVolume(newVolume: newVolume)
    }
    
    func decreaseVolume() {
        Logger.main.log("PlayerManager.decreaseVolume")
        
        let newVolume = Int(self.volume) - 10
        
        self.setVolume(newVolume: newVolume)
    }
    
    // MARK: - Audio device
    
    func setOutputDevice(audioDevice: AudioDevice) {
        Logger.main.log("PlayerManager.setOutputDevice")
        
        do {
            try AudioDevice.setDefaultDevice(for: .output, device: audioDevice)
        } catch {
            self.sendNotification(title: "Audio device not set", message: "Error setting output device")
        }
    }
    
    // MARK: - Open music app
    
    func openMusicApp() {
        Logger.main.log("PlayerManager.openMusicApp")
        
        var appPath: URL
        switch connectedApp {
        case .spotify:
            appPath = URL(fileURLWithPath: "/Applications/Spotify.app")
        case .appleMusic:
            appPath = URL(fileURLWithPath: "/System/Applications/Music.app")
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.openApplication(at: appPath, configuration: configuration)
    }
    
    // MARK: - Helpers
    
    private func formattedTimestamp(_ number: CGFloat) -> String {
        Logger.main.log("PlayerManager.formattedTimestamp")
        
        let formatter: DateComponentsFormatter = number >= 3600 ? .playbackTimeWithHours : .playbackTime
        return formatter.string(from: Double(number)) ?? Self.noPlaybackPositionPlaceholder
    }
    
    func isLikeAuthorized() -> Bool {
        Logger.main.log("PlayerManager.isLikeAuthorized")
        
        switch connectedApp {
        case .spotify:
            return false
        case .appleMusic:
            return true
        }
    }
}

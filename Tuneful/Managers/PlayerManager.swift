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
    
    var musicApp: PlayerProtocol!
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
            musicApp = SpotifyManager(app: spotifyApp!, notificationSubject: self.notificationSubject)
        case .appleMusic:
            guard appleMusicApp == nil else { return }
            appleMusicApp = SBApplication(bundleIdentifier: Constants.AppleMusic.bundleID)
            musicApp = AppleMusicManager(app: appleMusicApp!, notificationSubject: self.notificationSubject)
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
        Logger.main.log("Getting track info")
        
        getCurrentSeekerPosition()
        track = musicApp.getTrackInfo()
        trackDuration = musicApp.duration
        shuffleIsOn = musicApp.shuffleIsOn
        shuffleContextEnabled = musicApp.shuffleContextEnabled
        repeatContextEnabled = musicApp.repeatContextEnabled
        musicApp.getAlbumArt() { image in
            if let albumArt = image {
                self.updateAlbumArt(newAlbumArt: albumArt)
                self.updateMenuBarText(playerAppIsRunning: self.isRunning)
            }
        }
    }
    
    func updateAlbumArt(newAlbumArt: NSImage) {
        track.albumArt = newAlbumArt
    }
    
    // MARK: - Controls
    
    func togglePlayPause() {
        musicApp.playPause()
    }
    
    func previousTrack() {
        musicApp.previousTrack()
    }
    
    func nextTrack() {
        musicApp.nextTrack()
    }
    
    func toggleLoveTrack() {
        self.isLoved = musicApp.toggleLoveTrack()
    }
    
    func setShuffle() {
        shuffleIsOn = musicApp.setShuffle(shuffleIsOn: shuffleIsOn)
    }
    
    func setRepeat() {
        repeatIsOn = musicApp.setRepeat(repeatIsOn: repeatIsOn)
    }
    
    // MARK: - Seeker
    
    func getCurrentSeekerPosition() {
        if !isRunning { return }
        if isDraggingPlaybackPositionView { return }
        
        self.seekerPosition = musicApp.getCurrentSeekerPosition()
    }
    
    func seekTrack() {
        musicApp.seekTrack(seekerPosition: seekerPosition)
    }
    
    func updateFormattedPlaybackPosition() {
        if musicApp.playerPosition == nil {
            formattedPlaybackPosition = Self.noPlaybackPositionPlaceholder
            return
        }
        
        if isDraggingPlaybackPositionView {
            return
        }
        
        formattedPlaybackPosition = formattedTimestamp(seekerPosition)
    }
    
    func updateFormattedDuration() {
        formattedDuration = formattedTimestamp(musicApp.duration)
    }
    
    func draggingPlaybackPosition() {
        formattedPlaybackPosition = formattedTimestamp(seekerPosition)
    }
    
    // MARK: - Volume
    
    func getVolume() {
        volume = musicApp.volume
    }
    
    func setVolume(newVolume: Int) {
        var newVolume = newVolume
        if newVolume > 100 { newVolume = 100 }
        if newVolume < 0 { newVolume = 0 }
        
        musicApp.setVolume(volume: newVolume)
        
        volume = CGFloat(newVolume)
    }
    
    func increaseVolume() {
        let newVolume = Int(self.volume) + 10
        self.setVolume(newVolume: newVolume)
    }
    
    func decreaseVolume() {
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
        let appPath = musicApp.appPath
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
        return musicApp.isLikeAuthorized
    }
}

//
//  ContentViewModel.swift
//  Tuneful
//
//  Created by Martin Fekete on 29/07/2023.
//

import Combine
import Foundation
import SwiftUI
import ScriptingBridge
import ISSoundAdditions

class ContentViewModel: ObservableObject {
    
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.spotify
    @AppStorage("showPlayerWindow") var showPlayerWindow: Bool = true
    
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
    var formattedDuration = ContentViewModel.noPlaybackPositionPlaceholder
    var formattedPlaybackPosition = ContentViewModel.noPlaybackPositionPlaceholder
    
    // Volume
    @Published var volume: CGFloat = CGFloat(Sound.output.volume)
    @Published var isDraggingSoundVolumeSlider = false
    
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
        
        // Dont check for the song if not playing
        guard isRunning else { return }
        self.playStateOrTrackDidChange(nil)
        
        // Updating player state every 1 sec
        self.timerStartSignal.sink {
            print("showing")
            self.getCurrentSeekerPosition()
            self.updatePlayerStateCancellable = Timer.publish(
                every: 1, on: .main, in: .common
            )
            .autoconnect()
            .sink { _ in
                self.volume = CGFloat(Sound.output.volume)
                self.getCurrentSeekerPosition()
            }
        }
        .store(in: &self.cancellables)
        
        self.timerStopSignal.sink {
            print("closing")
            self.updatePlayerStateCancellable = nil
        }
        .store(in: &self.cancellables)
    }
    
    deinit {
        observer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupMusicApps() {
        print("Setting up music apps")
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
        if !showPlayerWindow {
            self.timerStartSignal.send()
        }
        self.volume = CGFloat(Sound.output.volume)
        popoverIsShown = true
    }

    @objc private func popoverIsClosing(_ notification: NSNotification) {
        if !showPlayerWindow {
            self.timerStopSignal.send()
        }
        popoverIsShown = false
    }
    
    // MARK: - Notification Handlers
    
    @objc func musicAppChanged(_ sender: NSNotification?) {
        self.setupMusicApps()
        
        print("Music app changes")
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
        
        print("The play state or the currently playing track changed")
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
    
    // MARK: - Media & Playback
    
    private func playStateChanged() -> Bool {
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
        isPlaying = connectedApp == .spotify
        ? spotifyApp?.playerState == .playing
        : appleMusicApp?.playerState == .playing
    }
    
    private func sendNotification(title: String, message: String) {
        let alertTitle = NSLocalizedString(
            title, //"Couldn't Retrieve Playback State",
            comment: ""
        )
        let alert = AlertItem(
            title: alertTitle,
            message: message//error.customizedLocalizedDescription
        )
        self.notificationSubject.send(alert)
    }
    
    func updatePlayerState() {
        
        print("Getting track information...")
        
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
                        print(error!.localizedDescription)
                        self?.sendNotification(title: "Couldn't Retrieve Playback State", message: error!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        self?.track.albumArt = NSImage(data: data) ?? NSImage()
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
            self.isLoved = appleMusicApp?.currentTrack?.loved ?? false
            
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
        switch connectedApp {
        case .spotify:
            spotifyApp?.playpause?()
        case .appleMusic:
            appleMusicApp?.playpause?()
        }
    }
    
    func previousTrack() {
        switch connectedApp {
        case .spotify:
            spotifyApp?.previousTrack?()
        case .appleMusic:
            appleMusicApp?.backTrack?()
        }
    }
    
    func nextTrack() {
        switch connectedApp {
        case .spotify:
            spotifyApp?.nextTrack?()
        case .appleMusic:
            appleMusicApp?.nextTrack?()
        }
    }
    
    func toggleLoveTrack() {
        switch connectedApp {
        case .appleMusic:
            toggleAppleMusicLove()
        case .spotify:
            return
        }
    }
    
    func toggleAppleMusicLove() {
        appleMusicApp?.currentTrack?.setLoved?(!self.isLoved)
        self.isLoved = !self.isLoved
    }
    
    func setShuffle() {
        self.shuffleIsOn.toggle()
        switch connectedApp {
        case .appleMusic:
            self.appleMusicApp?.setShuffleEnabled?(self.shuffleIsOn)
        case .spotify:
            self.spotifyApp?.setShuffling?(self.shuffleIsOn)
        }
    }
    
    func setRepeat() {
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
        guard isRunning else { return }
        if isDraggingPlaybackPositionView { return }
        
        self.seekerPosition = connectedApp == .spotify
        ? Double(spotifyApp?.playerPosition ?? 0)
        : Double(appleMusicApp?.playerPosition ?? 0)
    }
    
    func seekTrack() {
        switch connectedApp {
        case .appleMusic:
            appleMusicApp?.setPlayerPosition?(seekerPosition)
        case .spotify:
            spotifyApp?.setPlayerPosition?(seekerPosition)
        }
    }
    
    func updateFormattedPlaybackPosition() {
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
    
    func setVolume(newVolume: CGFloat) {
        do {
            try Sound.output.setVolume(Float(newVolume))
        } catch {
            self.sendNotification(title: "Volume not set", message: "Error setting the volume for output device")
        }
    }
    
    func increaseVolume() {
        var newVolume = volume + 0.1
        if newVolume > 1.0 {
            newVolume = 1.0
        }
        
        do {
            try Sound.output.setVolume(Float(newVolume))
            volume = newVolume
        } catch {
            self.sendNotification(title: "Volume not set", message: "Error setting the volume for output device")
        }
    }
    
    func decreaseVolume() {
        var newVolume = volume - 0.1
        if newVolume < 0.0 {
            newVolume = 0.0
        }
        
        do {
            try Sound.output.setVolume(Float(newVolume))
            volume = newVolume
        } catch {
            self.sendNotification(title: "Volume not set", message: "Error setting the volume for output device")
        }
    }
    
    // MARK: - Open music app
    
    func openMusicApp() {
        var spotifyPath: URL
        switch connectedApp {
        case .spotify:
            spotifyPath = URL(fileURLWithPath: "/Applications/Spotify.app")
        case .appleMusic:
            spotifyPath = URL(fileURLWithPath: "/System/Applications/Music.app")
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        NSWorkspace.shared.openApplication(at: spotifyPath, configuration: configuration)
    }
    
    // MARK: - Helpers
    
    private func formattedTimestamp(_ number: CGFloat) -> String {
        let formatter: DateComponentsFormatter = number >= 3600 ? .playbackTimeWithHours : .playbackTime
        return formatter.string(from: Double(number)) ?? Self.noPlaybackPositionPlaceholder
    }
    
    func isLikeAuthorized() -> Bool {
        if connectedApp == .appleMusic {
            return true
        }
        
        return false
    }
    
    // MARK: - Alert
    
    func showAppModalAlert(
        title: String,
        message: String
    ) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        
        let response = alert.runModal()
        if response.rawValue == 0 {
            NSApplication.shared.sendAction(#selector(AppDelegate.finishOnboarding), to: nil, from: nil);
        }
    }
}

//
//  PlayerManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 29/07/2023.
//

import os
import SwiftUI
import Combine
import ISSoundAdditions
import ScriptingBridge
import Defaults

public class PlayerManager: ObservableObject {
    var musicApp: PlayerProtocol!
    var playerAppProvider: PlayerAppProvider!
    
    var name: String { musicApp.appName }
    var isRunning: Bool { musicApp.isRunning() }
    var notification: String { musicApp.appNotification }
    
    // Notifications
    let notificationSubject = PassthroughSubject<AlertItem, Never>()
    
    // Track
    @Published var track = Track()
    @Published var isPlaying = false
    @Published var isLoved = false
    
    // Seeker
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
    static let noPlaybackPositionPlaceholder = "--:--"
    var formattedDuration = PlayerManager.noPlaybackPositionPlaceholder
    var formattedPlaybackPosition = PlayerManager.noPlaybackPositionPlaceholder
    
    // Volume
    @Published var volume: CGFloat = 50.0
    @Published var isDraggingSoundVolumeSlider = false
    
    // Audio devices
    @Published var audioDevices = AudioDevice.output.filter { $0.transportType != .virtual }
    
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
    
    // Notch
    private var notchInfo: DynamicNotchInfo!
    
    init() {
        
        // Music app and observers
        self.playerAppProvider = PlayerAppProvider(notificationSubject: self.notificationSubject)
        self.setupMusicAppsAndObservers()
        self.playStateOrTrackDidChange(nil)
        self.notchInfo = DynamicNotchInfo(playerManager: self)
        
        // Updating player state every 1 sec
        self.timerStartSignal.sink {
            self.getCurrentSeekerPosition()
            self.getVolume()
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
    
    // MARK: Setup
    
    private func setupMusicAppsAndObservers() {
        Logger.main.log("Setting up music app")
        
        self.musicApp = playerAppProvider.getPlayerApp()
        self.setupObservers()
    }
    
    public func setupObservers() {
        Logger.main.log("Setting up observers")
        
        // Clean up existing observers
        cleanupObservers()

        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(playStateOrTrackDidChange),
            name: NSNotification.Name(rawValue: musicApp.appNotification),
            object: nil,
            suspensionBehavior: .deliverImmediately
        )
        
        observer = UserDefaults.standard.observe(\.connectedApp, options: [.old, .new]) {
            defaults, change in
            self.setupMusicAppsAndObservers()
            self.playStateOrTrackDidChange(nil)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(popoverIsOpening),
            name: NSPopover.willShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(popoverIsClosing),
            name: NSPopover.didCloseNotification,
            object: nil
        )
    }
    
    private func cleanupObservers() {
        NotificationCenter.default.removeObserver(self)
        DistributedNotificationCenter.default().removeObserver(self)
        cancellables.removeAll()
        observer?.invalidate()
        observer = nil
    }
    
    @objc private func popoverIsOpening(_ notification: NSNotification) {
        self.startTimer()
        self.audioDevices = AudioDevice.output.filter { $0.transportType != .virtual }
        self.getVolume()
        self.getPlaybackSettingInfo()
        popoverIsShown = true
    }
    
    @objc private func popoverIsClosing(_ notification: NSNotification) {
        self.stopTimer()
        popoverIsShown = false
    }
    
    // MARK: Notification Handlers
    
    @objc func playStateOrTrackDidChange(_ sender: NSNotification?) {
        Logger.main.log("Play state or track changed")
        
        let musicAppKilled = sender?.userInfo?["Player State"] as? String == "Stopped"
        let isRunningFromNotification = !musicAppKilled && isRunning
        
        if musicAppKilled || !musicApp.isRunning() {
            self.track = Track()
            self.updateMenuBarText(playerAppIsRunning: isRunningFromNotification)
            return
        }

        self.musicApp.refreshInfo {  // Needs to be refreshed for system player to load song info asynchronously
            self.getPlayState()
            self.updateFormattedDuration()
            self.updateMenuBarText(playerAppIsRunning: isRunningFromNotification)
            
            // Get track info before it's loaded in getNewSongInfo() and compare
            // If previous song == current song => play state not changed
            let notificationTrack = self.musicApp.getTrackInfo()
            if self.track == notificationTrack { return }
            
            self.getPlaybackSettingInfo()
            self.getNewSongInfo()
        }
    }
    
    private func updateMenuBarText(playerAppIsRunning: Bool) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "UpdateMenuBarItem"), object: nil,
                userInfo: ["PlayerAppIsRunning": playerAppIsRunning])
        }
    }
    
    // MARK: Media & Playback
    
    private func playStateChanged() -> Bool {
        if (musicApp.isPlaying && isPlaying) || (!musicApp.isPlaying && !isPlaying) {
            return false
        }
        
        return true
    }
    
    private func getPlayState() {
        isPlaying = musicApp.isPlaying
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
    
    func getPlaybackSettingInfo() {
        Logger.main.log("Getting playback setting info")
        
        shuffleIsOn = musicApp.shuffleIsOn // TODO: Doesn't seem to be working correctly for Spotify
        shuffleContextEnabled = musicApp.shuffleContextEnabled
        repeatContextEnabled = musicApp.repeatContextEnabled
    }
    
    func getNewSongInfo() {
        Logger.main.log("Getting track info")
        
        withAnimation(Constants.mainAnimation) {
            getCurrentSeekerPosition()
            track = musicApp.getTrackInfo()
        }
        showNotchNotification()
        fetchAlbumArt(retryCount: 5)
        updateFormattedDuration()
    }
    
    func fetchAlbumArt(retryCount: Int = 5) {
        musicApp.getAlbumArt { result in
            if result != nil {
                self.updateAlbumArt(newAlbumArt: result!)
                self.updateMenuBarText(playerAppIsRunning: self.isRunning)
            } else if retryCount > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.fetchAlbumArt(retryCount: retryCount - 1)
                }
            } else {
                self.updateMenuBarText(playerAppIsRunning: self.isRunning)
                Logger.main.log("Failed to fetch album art")
            }
        }
    }
    
    func updateAlbumArt(newAlbumArt: FetchedAlbumArt) {
        withAnimation {
            self.track.avgAlbumColor = Color(nsColor: newAlbumArt.nsImage.averageColor ?? .gray)
            self.track.nsAlbumArt = newAlbumArt.nsImage
            self.track.albumArt = newAlbumArt.image
        }
    }
    
    func showNotchNotification() {
        if !Defaults[.notchEnabled] || !Defaults[.showSongNotification] || popoverIsShown {
            return
        }
        
        self.notchInfo.show(for: Defaults[.notificationDuration])
    }

    // MARK: Controls

    func togglePlayPause() {
        isPlaying = !isPlaying
        musicApp.playPause()
    }

    func previousTrack() {
        if track.isPodcast {
            self.seekerPosition = seekerPosition - Constants.podcastRewindDurationSec
            self.seekTrack()
        } else {
            musicApp.previousTrack()
        }
    }

    func nextTrack() {
        if track.isPodcast {
            self.seekerPosition = seekerPosition + Constants.podcastRewindDurationSec
            self.seekTrack()
        } else {
            musicApp.nextTrack()
        }
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

    // MARK: Seeker

    func getCurrentSeekerPosition() {
        if !musicApp.isRunning() { return }
        if isDraggingPlaybackPositionView { return }

        musicApp.refreshInfo {
            withAnimation {
                self.seekerPosition = self.musicApp.getCurrentSeekerPosition()
            }
        }
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
        formattedDuration = formattedTimestamp(track.duration)
    }

    func draggingPlaybackPosition() {
        formattedPlaybackPosition = formattedTimestamp(seekerPosition)
    }
    
    // MARK: Timer
    
    func startTimer() {
        if !musicApp.isRunning() { return }
        timerStopSignal.send() // So we don't invoke the timer more frequently
        timerStartSignal.send()
    }
    
    func stopTimer() {
        if !musicApp.isRunning() { return }
        if popoverIsShown || notchInfo.isVisible || Defaults[.showPlayerWindow] { return }
        timerStopSignal.send()
    }

    // MARK: Volume

    func getVolume() {
        if !musicApp.isRunning() { return }
        volume = musicApp.volume
    }

    func setVolume(newVolume: Int) {
        var newVolume = newVolume
        if newVolume > 100 { newVolume = 100 }
        if newVolume < 0 { newVolume = 0 }

        musicApp.setVolume(volume: newVolume)

        withAnimation {
            volume = CGFloat(newVolume)
        }
    }

    func increaseVolume() {
        let newVolume = Int(self.volume) + 10
        self.setVolume(newVolume: newVolume)
    }

    func decreaseVolume() {
        let newVolume = Int(self.volume) - 10
        self.setVolume(newVolume: newVolume)
    }

    // MARK: Audio device

    func setOutputDevice(audioDevice: AudioDevice) {
        Logger.main.log("PlayerManager.setOutputDevice")

        do {
            try AudioDevice.setDefaultDevice(for: .output, device: audioDevice)
        } catch {
            self.sendNotification(
                title: "Audio device not set", message: "Error setting output device")
        }
    }

    // MARK: Open music app

    func openMusicApp() {
        let appPath = musicApp.appPath
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.openApplication(at: appPath, configuration: configuration)
    }

    // MARK: Helpers

    private func formattedTimestamp(_ number: CGFloat) -> String {
        let formatter: DateComponentsFormatter =
            number >= 3600 ? .playbackTimeWithHours : .playbackTime
        return formatter.string(from: Double(number)) ?? Self.noPlaybackPositionPlaceholder
    }

    func isLikeAuthorized() -> Bool {
        return musicApp.isLikeAuthorized
    }
    
    // MARK: Notch
    
    func deinitializeNotch() {
        notchInfo.deinitializeNotchWindow()
    }
    
    func initializeNotch() {
        notchInfo.initializeNotchWindow()
    }
}

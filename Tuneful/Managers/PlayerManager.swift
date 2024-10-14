//
//  PlayerManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 29/07/2023.
//

import Combine
import Foundation
import ISSoundAdditions
import ScriptingBridge
import SwiftUI
import os

class PlayerManager: ObservableObject {
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.spotify
    @AppStorage("showPlayerWindow") private var showPlayerWindow: Bool = true
    @AppStorage("showSongNotification") private var showSongNotification = true
    @AppStorage("notificationDuration") private var notificationDuration = 2.0
    
    var musicApp: PlayerProtocol!
    
    // TODO: Media remote framework for other music players
    //    private let MRMediaRemoteRegisterForNowPlayingNotifications: @convention(c) (DispatchQueue) -> Void
    
    var name: String { musicApp.appName }
    var isRunning: Bool { musicApp.isRunning }
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
    static let noPlaybackPositionPlaceholder = "- : -"
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
        // TODO: Media remote framework for other music players
        //        let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
        //        let MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString)
        //        self.MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: (@convention(c) (DispatchQueue) -> Void).self)
        
        // Music app and observers
        self.setupMusicAppsAndObservers()
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
    
    // MARK: Setup
    
    private func setupMusicAppsAndObservers() {
        Logger.main.log("Setting up music app")
        
        // TODO: Media remote framework for other music players
        //        musicApp = SystemPlayerManager(notificationSubject: self.notificationSubject)
        
        switch connectedApp {
        case .spotify:
            musicApp = SpotifyManager(notificationSubject: self.notificationSubject)
        case .appleMusic:
            musicApp = AppleMusicManager(notificationSubject: self.notificationSubject)
        }
        
        self.setupObservers()
    }
    
    public func setupObservers() {
        Logger.main.log("Setting up observers")
        
        // TODO: Media remote framework for other music players
        //        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)
        //
        //        NotificationCenter.default.publisher(for: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"))
        //            .sink { [weak self] _ in
        //                self!.playStateOrTrackDidChange(nil)
        //            }
        //            .store(in: &cancellables)
        
        // Remove existing observers
        NotificationCenter.default.removeObserver(self)
        DistributedNotificationCenter.default().removeObserver(self)
        observer?.invalidate()
        
        observer = UserDefaults.standard.observe(\.connectedApp, options: [.old, .new]) {
            defaults, change in
            self.setupMusicAppsAndObservers()
            self.playStateOrTrackDidChange(
                NSNotification(
                    name: Notification.Name(Constants.playerAppChangedMessage), object: nil))
        }
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(playStateOrTrackDidChange),
            name: NSNotification.Name(rawValue: musicApp.appNotification),
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
        self.audioDevices = AudioDevice.output.filter { $0.transportType != .virtual }
        self.getVolume()
        self.getPlaybackSettingInfo()
        
        popoverIsShown = true
    }
    
    @objc private func popoverIsClosing(_ notification: NSNotification) {
        if !showPlayerWindow {
            self.timerStopSignal.send()
        }
        
        popoverIsShown = false
    }
    
    // MARK: Notification Handlers
    
    @objc func playStateOrTrackDidChange(_ sender: NSNotification?) {
        Logger.main.log("Play state or track changed")
        
        let musicAppKilled = sender?.userInfo?["Player State"] as? String == "Stopped"
        let isRunningFromNotification = !musicAppKilled && isRunning
        let playerAppChanged = sender?.name.rawValue == Constants.playerAppChangedMessage
        
        if !isRunningFromNotification || playerAppChanged && !isRunning {
            self.track = Track()
            self.track.albumArt = musicApp.defaultAlbumArt
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
        
        getCurrentSeekerPosition()
        track = musicApp.getTrackInfo()
        fetchAlbumArt(retryCount: 5)
        updateFormattedDuration()
    }
    
    func fetchAlbumArt(retryCount: Int = 5) {
        musicApp.getAlbumArt { result in
            if result.isAlbumArt {
                self.updateAlbumArt(newAlbumArt: result.image)
                self.updateMenuBarText(playerAppIsRunning: self.isRunning)
                self.updateNotchInfo(albumArt: result)
            } else if retryCount > 0 {
                self.updateAlbumArt(newAlbumArt: result.image)
                self.updateMenuBarText(playerAppIsRunning: self.isRunning)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.fetchAlbumArt(retryCount: retryCount - 1)
                }
            } else {
                self.updateAlbumArt(newAlbumArt: self.musicApp.defaultAlbumArt)
                self.updateMenuBarText(playerAppIsRunning: self.isRunning)
                Logger.main.log("Failed to fetch album art")
            }
        }
    }
    
    func updateAlbumArt(newAlbumArt: NSImage) {
        DispatchQueue.main.async {
            withAnimation(.none) {
                self.track.albumArt = newAlbumArt
            }
        }
    }
    
    func updateNotchInfo(albumArt: FetchedAlbumArt) {
        if !showSongNotification || popoverIsShown {
            return
        }
        
        self.notchInfo?.hide()
        self.notchInfo = DynamicNotchInfo(
            icon: Image(nsImage: albumArt.image.roundImage(withSize: NSSize(width: 70, height: 70), radius: 10)),
            title: self.track.title,
            description: self.track.album,
            onTap: self.openMusicApp
        )
        self.notchInfo.show(for: notificationDuration)
    }

    // MARK: Controls

    func togglePlayPause() {
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
        if !isRunning { return }
        if isDraggingPlaybackPositionView { return }

        musicApp.refreshInfo {
            self.seekerPosition = self.musicApp.getCurrentSeekerPosition()
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

    // MARK: Volume

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
}

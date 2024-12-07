//
//  Defaults+Extensions.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/6/24.
//

import Defaults

extension Defaults.Keys {
    static let notchEnabled = Key<Bool>("notchEnabled", default: true)
    static let showPlayerWindow = Key<Bool>("showPlayerWindow", default: true)
    static let viewedOnboarding = Key<Bool>("viewedOnboarding", default: false)
    static let popoverIsEnabled = Key<Bool>("popoverIsEnabled", default: true)
    static let miniPlayerWindowOnTop = Key<Bool>("miniPlayerWindowOnTop", default: true)
    static let hideMenuBarItemWhenNotPlaying = Key<Bool>("hideMenuBarItemWhenNotPlaying", default: false)
    static let connectedApp = Key<ConnectedApps>("connectedApp", default: .appleMusic)
    static let popoverType = Key<PopoverType>("popoverType", default: .full)
    static let miniPlayerType = Key<MiniPlayerType>("miniPlayerType", default: .minimal)
    static let menuBarItemWidth = Key<Double>("menuBarItemWidth", default: 150)
    static let statusBarIcon = Key<StatusBarIcon>("statusBarIcon", default: .albumArt)
    static let trackInfoDetails = Key<StatusBarTrackDetails>("trackInfoDetails", default: .artistAndSong)
    static let showStatusBarTrackInfo = Key<ShowStatusBarTrackInfo>("showStatusBarTrackInfo", default: .always)
    static let showMenuBarPlaybackControls = Key<Bool>("showMenuBarPlaybackControls", default: false)
    static let scrollingTrackInfo = Key<Bool>("scrollingTrackInfo", default: false)
    static let showEqWhenPlayingMusic = Key<Bool>("showEqWhenPlayingMusic", default: true)
    static let windowPosition = Key<String>("windowPosition", default: "10,10")
    static let showSongNotification = Key<Bool>("showSongNotification", default: true)
    static let notificationDuration = Key<Double>("notificationDuration", default: 2)
    static let popoverBackground = Key<BackgroundType>("popoverBackground", default: .semiTransparent)
}

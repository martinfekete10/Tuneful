//
//  Constants.swift
//  Tuneful
//
//  Source: [Jukebox](https://github.com/Jaysce/Jukebox)
//

import AppKit
import SwiftUI

enum Constants {
    static let podcastThresholdDurationSec = 900.0
    static let podcastRewindDurationSec = 15.0
    static let playerAppChangedMessage = "Player app changed"
    static let popoverWidth = 210.0
    static let fullPopoverHeight = 345.0
    static let compactPopoverHeight = 265.0
    static let settingsWindowWidth: CGFloat = 500
    
    enum Opacity {
        static let primaryOpacity = 0.8
        static let primaryOpacity2 = 0.6
        static let secondaryOpacity = 0.4
        static let ternaryOpacity = 0.2
    }
    
    enum AppInfo {
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    enum Spotify {
        static let bundleID = "com.spotify.client"
    }
    
    enum AppleMusic {
        static let bundleID = "com.apple.Music"
    }
    
    enum StatusBar {
        static let marqueeFont = NSFont.systemFont(ofSize: 13, weight: .regular)
        static let imageWidth = 30.0
    }
    
    static var mainAnimation: Animation {
        Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
    }
}

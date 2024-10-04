//
//  Constants.swift
//  Tuneful
//
//  Source: [Jukebox](https://github.com/Jaysce/Jukebox)
//

import Foundation
import AppKit

enum Constants {
    
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
}

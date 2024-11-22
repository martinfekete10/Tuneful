//
//  SupportedApps.swift
//  Tuneful
//
//  Created by Martin Fekete on 28/07/2023.
//

import Foundation
import SwiftUI

enum ConnectedApps: String, Equatable, CaseIterable {
    case spotify = "Spotify"
    case appleMusic = "Apple Music"
//    case system = "System player"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    
    var isInstalled: Bool {
        switch self {
        case .spotify:
            print(FileManager.default.fileExists(atPath: "/Applications/Spotify.app"))
            return FileManager.default.fileExists(atPath: "/Applications/Spotify.app")
        case .appleMusic:
            print(FileManager.default.fileExists(atPath: "/System/Applications/Music.app"))
            return FileManager.default.fileExists(atPath: "/System/Applications/Music.app")
        }
    }
}

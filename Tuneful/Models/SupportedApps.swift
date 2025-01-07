//
//  SupportedApps.swift
//  Tuneful
//
//  Created by Martin Fekete on 28/07/2023.
//

import Foundation
import SwiftUI
import Defaults

enum ConnectedApps: String, Equatable, CaseIterable, LuminarePickerData, Defaults.Serializable {
    case appleMusic = "Apple Music"
    case spotify = "Spotify"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    
    var selectable: Bool {
        switch self {
        case .spotify:
            return FileManager.default.fileExists(atPath: "/Applications/Spotify.app")
        case .appleMusic:
            return FileManager.default.fileExists(atPath: "/System/Applications/Music.app")
        }
    }
    
    var getIcon: Image {
        switch self {
        case .spotify:
             return Image(.spotifyIcon)
        case .appleMusic:
            return Image(.appleMusicIcon)
        }
    }
}

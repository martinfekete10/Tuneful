//
//  StatusBarTrackDetails.swift
//  Tuneful
//
//  Created by Martin Fekete on 07/01/2024.
//

import SwiftUI
import Defaults

enum StatusBarTrackDetails: String, Equatable, CaseIterable, Defaults.Serializable {
    
    case artistAndSong = "Artist and song"
    case artist = "Artist"
    case song = "Song"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

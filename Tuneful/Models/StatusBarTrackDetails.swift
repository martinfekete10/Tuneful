//
//  StatusBarTrackDetails.swift
//  Tuneful
//
//  Created by Martin Fekete on 07/01/2024.
//

import SwiftUI

enum StatusBarTrackDetails: String, Equatable, CaseIterable {
    
    case artistAndSong = "Artist and song"
    case artist = "Artist"
    case song = "Song"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

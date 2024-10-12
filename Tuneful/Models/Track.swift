//
//  Track.swift
//  Tuneful
//
//  Created by Martin Fekete on 28/07/2023.
//

import Foundation
import SwiftUI

struct Track: Equatable {
    var title = ""
    var artist = ""
    var album = ""
    var albumArt = NSImage()
    var duration: CGFloat = 0.0
    var isLoved = false
    var isPodcast: Bool { self.duration > Constants.podcastThresholdDurationSec }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        if lhs.title == "" && lhs.artist == "" && lhs.album == "" {
            return false // Not initialised, can't compare
        }
        return lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.album == rhs.album
    }
}


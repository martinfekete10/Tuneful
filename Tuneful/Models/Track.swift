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
    var albumArtImage: Image {
        get { return Image(nsImage: albumArt.roundImage(withSize: NSSize(width: 50, height: 50), radius: 10)) }
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        if lhs.title == "" && lhs.artist == "" && lhs.album == "" {
            return false // Not initialised, can't compare
        }
        return lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.album == rhs.album
    }
    
    func isEmpty() -> Bool {
        if self.title == "" && self.artist == "" && self.album == "" {
            return true 
        }
        return false
    }
}


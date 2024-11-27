//
//  Track.swift
//  Tuneful
//
//  Created by Martin Fekete on 28/07/2023.
//

import Foundation
import SwiftUI

struct Track: Equatable {
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var albumArt: Image = Image(.defaultAlbumart)
    var nsAlbumArt: NSImage = NSImage()
    var duration: CGFloat = 0.0
    var isLoved: Bool = false
    var isPodcast: Bool { self.duration > Constants.podcastThresholdDurationSec }
//    var albumArtImage: Image {
//        get { return Image(nsImage: albumArt.roundImage(withSize: NSSize(width: 50, height: 50), radius: 10)) }
//    }
    
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


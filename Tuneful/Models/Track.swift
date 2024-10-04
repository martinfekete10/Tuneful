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
    var loved = false
    var albumArt = NSImage()
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        if lhs.title == "" && lhs.artist == "" && lhs.album == "" {
            return false // Not initialised, can't compare
        }
        return lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.album == rhs.album
    }
}


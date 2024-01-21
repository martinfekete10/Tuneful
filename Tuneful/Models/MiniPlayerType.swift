//
//  MiniPlayerType.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/01/2024.
//

import SwiftUI

enum MiniPlayerType: String, Equatable, CaseIterable {
    
    case full = "Full"
    case albumArt = "Album art"
    case minimal = "Minimal"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


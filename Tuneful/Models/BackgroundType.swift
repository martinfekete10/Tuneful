//
//  BackgroundType.swift
//  Tuneful
//
//  Created by Martin Fekete on 17/01/2024.
//

import SwiftUI

enum BackgroundType: String, Equatable, CaseIterable {
    
    case transparent = "Transparent"
    case albumArt = "Album art"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


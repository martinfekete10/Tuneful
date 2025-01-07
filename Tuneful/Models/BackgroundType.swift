//
//  BackgroundType.swift
//  Tuneful
//
//  Created by Martin Fekete on 17/01/2024.
//

import SwiftUI
import Defaults

enum BackgroundType: String, Equatable, CaseIterable, Defaults.Serializable {
    case glow = "Tint"
    case transparent = "Transparent"
    case albumArt = "Album art"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


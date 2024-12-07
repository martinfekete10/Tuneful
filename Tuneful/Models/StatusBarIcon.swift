//
//  StatusBarIcon.swift
//  Tuneful
//
//  Created by Martin Fekete on 06/01/2024.
//

import SwiftUI
import Defaults

enum StatusBarIcon: String, Equatable, CaseIterable, Defaults.Serializable {
    case albumArt = "Album art"
    case appIcon = "App icon"
    case hidden = "Hidden"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

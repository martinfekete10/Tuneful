//
//  StatusBarIcon.swift
//  Tuneful
//
//  Created by Martin Fekete on 06/01/2024.
//

import SwiftUI

enum StatusBarIcon: String, Equatable, CaseIterable {
    case albumArt = "Album art"
    case appIcon = "App icon"
    case hidden = "Hidden"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

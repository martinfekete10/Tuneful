//
//  ShowStatusBarTrackInfo.swift
//  Tuneful
//
//  Created by Martin Fekete on 25/01/2024.
//

import SwiftUI
import Defaults

enum ShowStatusBarTrackInfo: String, Equatable, CaseIterable, Defaults.Serializable {
    
    case always = "Always"
    case whenPlaying = "When playing"
    case never = "Never"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

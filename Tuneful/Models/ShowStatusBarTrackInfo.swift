//
//  ShowStatusBarTrackInfo.swift
//  Tuneful
//
//  Created by Martin Fekete on 25/01/2024.
//

import SwiftUI

enum ShowStatusBarTrackInfo: String, Equatable, CaseIterable {
    
    case always = "Always"
    case whenPlaying = "When playing"
    case never = "Never"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

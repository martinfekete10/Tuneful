//
//  SupportedApps.swift
//  Tuneful
//
//  Created by Martin Fekete on 28/07/2023.
//

import Foundation
import SwiftUI

enum ConnectedApps: String, Equatable, CaseIterable {
    case spotify = "Spotify"
    case appleMusic = "Apple Music"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

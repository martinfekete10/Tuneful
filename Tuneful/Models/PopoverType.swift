//
//  PopoverType.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/06/2024.
//

import SwiftUI
import Defaults

enum PopoverType: String, Equatable, CaseIterable, Defaults.Serializable {
    case full = "Full"
    case minimal = "Minimal"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


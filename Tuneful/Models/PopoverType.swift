//
//  PopoverType.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/06/2024.
//

import SwiftUI

enum PopoverType: String, Equatable, CaseIterable {
    
    case full = "Full"
    case minimal = "Minimal"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


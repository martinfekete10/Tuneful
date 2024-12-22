//
//  MiniPlayerScaleFactor.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/12/2024.
//

import Defaults
import SwiftUICore

enum MiniPlayerScaleFactor: Double, Equatable, CaseIterable, Defaults.Serializable {
    case small = 0.75
    case regular = 1
    case large = 1.25
    
    var localizedName: String {
        switch self {
        case .small: return "Small"
        case .regular: return "Regular"
        case .large: return "Large"
        }
    }
    
    var trackFontSize: Font {
        switch self {
        case .small: return .system(size: 10)
        case .regular: return .system(size: 13)
        case .large: return .system(size: 16)
        }
    }
}

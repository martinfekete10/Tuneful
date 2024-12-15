//
//  MiniPlayerType.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/01/2024.
//

import SwiftUI
import Defaults

enum MiniPlayerType: String, Equatable, CaseIterable, Defaults.Serializable {
    case full = "Full"
    case minimal = "Minimal"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .full: MiniPlayerView()
        case .minimal: CompactMiniPlayerView()
        }
    }
    
    func getWindowSize() -> NSSize {
        switch self {
        case .full: return NSSize(width: 300, height: 145)
        case .minimal: return NSSize(width: 145, height: 145)
        }
    }
}


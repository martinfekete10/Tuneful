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
    case vertical = "Vertical"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .full: MiniPlayerView()
        case .minimal: CompactMiniPlayerView()
        case .vertical: VerticalMiniPlayerView()
        }
    }
    
    var size: CGSize {
        switch self {
        case .full:
            return MiniPlayerView().size
        case .minimal:
            return CompactMiniPlayerView().size
        case .vertical:
            return VerticalMiniPlayerView().size
        }
    }
}


//
//  MiniPlayerType.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/01/2024.
//

import SwiftUI
import Defaults

enum MiniPlayerType: String, Equatable, CaseIterable, Defaults.Serializable {
    case minimal = "Minimal"
    case horizontal = "Full"
    case vertical = "Vertical"
    
    var localizedName: String {
        switch self {
        case .minimal: "Minimal"
        case .horizontal: "Horizontal"
        case .vertical: "Vertical"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .minimal: CompactMiniPlayerView()
        case .horizontal: HorizontalMiniPlayerView()
        case .vertical: VerticalMiniPlayerView()
        }
    }
}


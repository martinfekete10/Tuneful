//
//  BackgroundView.swift
//  Tuneful
//
//  Created by Martin Fekete on 08/12/2024.
//

import SwiftUI
import Defaults

struct BackgroundView: View {
    @EnvironmentObject private var playerManager: PlayerManager
    
    var background: BackgroundType
    var albumArtSize: CGFloat = 190
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    
    var body: some View {
        switch background {
        case .glow:
            playerManager.track.albumArt
                .resizable()
                .frame(width: albumArtSize, height: albumArtSize)
                .offset(x: xOffset != 0 ? xOffset + 10 : xOffset, y: yOffset != 0 ? yOffset + 20 : yOffset)
            
            VisualEffectView(material: .popover, blendingMode: .withinWindow)
        case .albumArt:
            playerManager.track.albumArt
                .resizable()
            VisualEffectView(material: .popover, blendingMode: .withinWindow)
        case .transparent:
            EmptyView()
        }
                    
    }
}

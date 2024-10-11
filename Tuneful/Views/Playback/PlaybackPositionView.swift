//
//  PlaybackPositionView.swift
//  Tuneful
//
//  Created by Martin Fekete on 18/08/2023.
//

import Foundation
import Combine
import SwiftUI

struct PlaybackPositionView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @AppStorage("showPlayerWindow") var showPlayerWindow: Bool = true
    
    var body: some View {
        VStack(spacing: -5) {
            CustomSliderView(
                value: $playerManager.seekerPosition,
                isDragging: $playerManager.isDraggingPlaybackPositionView,
                range: 0...playerManager.track.duration,
                knobDiameter: 10,
                knobColor: .white,
                knobScaleEffectMagnitude: 1.3,
                knobAnimation: .linear(duration: 0.1),
                leadingRectangleColor: .playbackPositionLeadingRectangle,
                onEndedDragging: { _ in self.playerManager.seekTrack() }
            )
            .padding(.bottom, 5)
            
            HStack {
                Text(playerManager.formattedPlaybackPosition)
                    .font(.caption)
                Spacer()
                Text(playerManager.formattedDuration)
                    .font(.caption)
            }
            .padding(.horizontal, 5)
        }
    }
}

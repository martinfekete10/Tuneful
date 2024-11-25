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
    
    var body: some View {
        VStack(spacing: 0) {
            CustomSliderView(
                value: $playerManager.seekerPosition,
                isDragging: $playerManager.isDraggingPlaybackPositionView,
                range: 0...playerManager.track.duration,
                onEndedDragging: { _ in self.playerManager.seekTrack() }
            )
            .padding(.bottom, 10)
            .frame(height: 15)
            
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

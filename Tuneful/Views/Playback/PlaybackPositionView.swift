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
    var sliderHeight: CGFloat = 7
    var inline: Bool = false
    
    var body: some View {
        if !inline {
            VStack(spacing: 0) {
                CustomSliderView(
                    value: $playerManager.seekerPosition,
                    isDragging: $playerManager.isDraggingPlaybackPositionView,
                    range: 0...playerManager.track.duration,
                    sliderHeight: sliderHeight,
                    onEndedDragging: { _ in self.playerManager.seekTrack() }
                )
                .padding(.bottom, 7)
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
        } else {
            HStack(spacing: 10) {
                Text(playerManager.formattedPlaybackPosition)
                    .font(.caption)
                
                CustomSliderView(
                    value: $playerManager.seekerPosition,
                    isDragging: $playerManager.isDraggingPlaybackPositionView,
                    range: 0...playerManager.track.duration,
                    sliderHeight: sliderHeight,
                    onEndedDragging: { _ in self.playerManager.seekTrack() }
                )
                .frame(height: 15)
                
                Text(playerManager.formattedDuration)
                    .font(.caption)
            }
        }
    }
}

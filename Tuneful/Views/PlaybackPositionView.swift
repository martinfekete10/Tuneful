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
    
    @EnvironmentObject var contentViewModel: ContentViewModel
    @AppStorage("showPlayerWindow") var showPlayerWindow: Bool = true
    
    var duration: CGFloat {
        return CGFloat(contentViewModel.trackDuration)
    }
    
    var body: some View {
        VStack(spacing: -5) {
            CustomSliderView(
                value: $contentViewModel.seekerPosition,
                isDragging: $contentViewModel.isDraggingPlaybackPositionView,
                range: 0...duration,
                knobDiameter: 10,
                knobColor: .white,
                knobScaleEffectMagnitude: 1.3,
                knobAnimation: .linear(duration: 0.1),
                leadingRectangleColor: .playbackPositionLeadingRectangle,
                onEndedDragging: { _ in self.contentViewModel.seekTrack() }
            )
            .padding(.bottom, 5)
            
            HStack {
                Text(contentViewModel.formattedPlaybackPosition)
                    .font(.caption)
                Spacer()
                Text(contentViewModel.formattedDuration)
                    .font(.caption)
            }
            .padding(.horizontal, 5)
        }
    }
}

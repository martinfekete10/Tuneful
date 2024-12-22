//
//  CompactMiniPlayerView.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/01/2024.
//

import SwiftUI
import Defaults

struct CompactMiniPlayerView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @State private var isShowingPlaybackControls = false
    
    @Default(.miniPlayerScaleFactor) private var miniPlayerScaleFactor
    @Default(.miniPlayerBackground) private var miniPlayerBackground
    
    private var imageSize: CGFloat = 140.0
    private var cornerRadius: CGFloat = 12.5
    private var playbackButtonSize: CGFloat = 15.0
    private var playPauseButtonSize: CGFloat = 25.0

    var body: some View {
        ZStack {
            AlbumArtView(imageSize: self.imageSize * miniPlayerScaleFactor.rawValue)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .dragWindowWithClick()
            
            PlaybackButtonsView(playButtonSize: 17.5 * miniPlayerScaleFactor.rawValue, hideShuffleAndRepeat: true, spacing: 17.5 * miniPlayerScaleFactor.rawValue)
                .padding(15 * miniPlayerScaleFactor.rawValue)
                .background(
                    VisualEffectView(material: .popover, blendingMode: .withinWindow)
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(.quaternary, lineWidth: 1)
                        }
                )
                .cornerRadius(cornerRadius)
                .opacity(isShowingPlaybackControls ? 1 : 0)
        }
        .onHover { _ in
            withAnimation(.linear(duration: 0.2)) {
                self.isShowingPlaybackControls.toggle()
            }
        }
    }
}

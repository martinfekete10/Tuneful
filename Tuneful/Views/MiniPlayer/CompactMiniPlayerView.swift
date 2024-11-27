//
//  CompactMiniPlayerView.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/01/2024.
//

import SwiftUI
import MediaPlayer

struct CompactMiniPlayerView: View {
    
    @EnvironmentObject var playerManager: PlayerManager
    @AppStorage("miniPlayerBackground") var miniPlayerBackground: BackgroundType = .albumArt
    @State private var isShowingPlaybackControls = false
    
    private var imageSize: CGFloat = 140.0
    private var cornerRadius: CGFloat = 12.5
    private var playbackButtonSize: CGFloat = 15.0
    private var playPauseButtonSize: CGFloat = 25.0

    var body: some View {
        ZStack {
            if miniPlayerBackground == .albumArt && playerManager.isRunning {
                playerManager.track.albumArt
                    .resizable()
                    .scaledToFill()
                VisualEffectView(material: .popover, blendingMode: .withinWindow)
            }
            
            if !playerManager.isRunning || playerManager.track.isEmpty() {
                Text("Please open \(playerManager.name) to use Tuneful")
                    .foregroundColor(.primary.opacity(0.4))
                    .font(.system(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(15)
                    .padding(.bottom, 20)
            } else {
                AlbumArtView(imageSize: self.imageSize)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .dragWindowWithClick()

                PlaybackButtonsView(playButtonSize: 20, hideShuffleAndRepeat: true)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
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
        }
        .frame(width: 155, height: 155)
        .onHover { _ in
            withAnimation(.linear(duration: 0.2)) {
                self.isShowingPlaybackControls.toggle()
            }
        }
        .overlay(
            NotificationView()
        )
        .background(
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
    }
}

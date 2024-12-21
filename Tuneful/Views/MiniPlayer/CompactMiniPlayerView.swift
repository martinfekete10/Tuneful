//
//  CompactMiniPlayerView.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/01/2024.
//

import SwiftUI
import MediaPlayer
import Defaults

struct CompactMiniPlayerView: View, MiniPlayerViewProtocol {
    @EnvironmentObject var playerManager: PlayerManager
    @State private var isShowingPlaybackControls = false
    @State var size = CGSize(width: 150, height: 150)
    
    @Default(.miniPlayerBackground) private var miniPlayerBackground
    
    private var imageSize: CGFloat = 140.0
    private var cornerRadius: CGFloat = 12.5
    private var playbackButtonSize: CGFloat = 15.0
    private var playPauseButtonSize: CGFloat = 25.0

    var body: some View {
        ZStack {
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
                
                PlaybackButtonsView(playButtonSize: 17.5, hideShuffleAndRepeat: true, spacing: 17.5)
                    .padding(15)
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
        .padding(7.5)
        .onHover { _ in
            withAnimation(.linear(duration: 0.2)) {
                self.isShowingPlaybackControls.toggle()
            }
        }
        .overlay(
            NotificationView()
        )
        .background(
            GeometryReader { proxy in
                ZStack {
                    VisualEffectView(material: .popover, blendingMode: .behindWindow)
                    BackgroundView(background: miniPlayerBackground, xOffset: -80)
                }
                .onAppear {
                    size = proxy.size
                }
            }
        )
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
    }
}

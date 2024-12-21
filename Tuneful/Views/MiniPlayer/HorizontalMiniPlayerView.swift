//
//  ContentView.swift
//  Tuneful
//
//  Created by Martin Fekete on 27/07/2023.
//

import SwiftUI
import MediaPlayer
import Defaults

struct HorizontalMiniPlayerView: View, MiniPlayerViewProtocol {
    @EnvironmentObject var playerManager: PlayerManager
    @State private var isShowingPlaybackControls = false
    @State var size = CGSize(width: 200, height: 150)
    
    @Default(.miniPlayerScaleFactor) private var miniPlayerScaleFactor
    @Default(.miniPlayerBackground) private var miniPlayerBackground
    
    private var imageSize: CGFloat = 140.0

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
                HStack(spacing: 10 * miniPlayerScaleFactor.rawValue) {
                    ZStack {
                        AlbumArtView(imageSize: self.imageSize * miniPlayerScaleFactor.rawValue)
                            .dragWindowWithClick()
                        
                        AddToFavoritesView()
                            .opacity(isShowingPlaybackControls ? 1 : 0)
                    }
                    .onHover { _ in
                        withAnimation(.linear(duration: 0.1)) {
                            self.isShowingPlaybackControls.toggle()
                        }
                    }
                    
                    VStack(spacing: 10 * miniPlayerScaleFactor.rawValue) {
                        Button(action: playerManager.openMusicApp) {
                            VStack {
                                Text(playerManager.track.title)
                                    .font(.body)
                                    .bold()
                                    .lineLimit(1)
                                
                                Text(playerManager.track.artist)
                                    .font(.body)
                                    .lineLimit(1)
                            }
                            .tapAnimation() {
                                self.playerManager.openMusicApp()
                            }
                        }
                        .pressButtonStyle()
                        
                        if playerManager.musicApp.playbackSeekerEnabled {
                            PlaybackPositionView()
                        }
                        
                        PlaybackButtonsView(playButtonSize: 17.5 * miniPlayerScaleFactor.rawValue, spacing: 12.5 * miniPlayerScaleFactor.rawValue)
                    }
                    .frame(width: imageSize * miniPlayerScaleFactor.rawValue) // Both sides should be the same
                    .opacity(0.75)
                }
            }
        }
        .padding(10 * miniPlayerScaleFactor.rawValue)
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
    }
}

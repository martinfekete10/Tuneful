//
//  ContentView.swift
//  Tuneful
//
//  Created by Martin Fekete on 27/07/2023.
//

import SwiftUI
import Defaults

struct VerticalMiniPlayerView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @State private var isShowingPlaybackControls = false
    
    @Default(.miniPlayerScaleFactor) private var miniPlayerScaleFactor
    @Default(.miniPlayerBackground) private var miniPlayerBackground
    
    private var imageSize: CGFloat = 140.0

    var body: some View {
        VStack(spacing: 10 * miniPlayerScaleFactor.rawValue) {
            ZStack {
                AlbumArtView(imageSize: imageSize * miniPlayerScaleFactor.rawValue)
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
                PlaybackButtonsView(playButtonSize: 17.5 * miniPlayerScaleFactor.rawValue, hideShuffleAndRepeat: true, spacing: 17.5 * miniPlayerScaleFactor.rawValue)
                
                Button(action: playerManager.openMusicApp) {
                    VStack {
                        Text(playerManager.track.title)
                            .font(miniPlayerScaleFactor.trackFontSize)
                            .bold()
                            .lineLimit(1)
                        
                        Text(playerManager.track.artist)
                            .font(miniPlayerScaleFactor.trackFontSize)
                            .lineLimit(1)
                    }
                    .tapAnimation() {
                        self.playerManager.openMusicApp()
                    }
                }
                .pressButtonStyle()
            }
            .frame(width: self.imageSize * miniPlayerScaleFactor.rawValue)
            .opacity(0.75)
        }
    }
}

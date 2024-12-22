//
//  ContentView.swift
//  Tuneful
//
//  Created by Martin Fekete on 27/07/2023.
//

import SwiftUI
import Defaults

struct HorizontalMiniPlayerView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @State private var isShowingPlaybackControls = false
    
    @Default(.miniPlayerScaleFactor) private var miniPlayerScaleFactor
    @Default(.miniPlayerBackground) private var miniPlayerBackground
    
    private var imageSize: CGFloat = 140.0

    var body: some View {
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

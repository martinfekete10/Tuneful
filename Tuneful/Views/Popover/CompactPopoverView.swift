//
//  CompactPopoverView.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/06/2024.
//

import SwiftUI
import Defaults

struct CompactPopoverView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @State private var isShowingPlaybackControls = false
    @Default(.popoverBackground) private var popoverBackground
    
    var body: some View {
        ZStack {
            if !playerManager.isRunning || playerManager.track.isEmpty() {
                Text("Please open \(playerManager.name) to use Tuneful")
                    .foregroundColor(.primary.opacity(Constants.Opacity.secondaryOpacity))
                    .font(.system(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack {
                    ZStack {
                        AlbumArtView(imageSize: 190)
            
                        AddToFavoritesView()
                            .opacity(isShowingPlaybackControls ? 1 : 0)
                            .offset(y: -30)
                        
                        VStack {
                            Spacer()
                                .frame(height: playerManager.musicApp.playbackSeekerEnabled ? 90 : 125)
                            
                            VStack(alignment: .center) {
                                PlaybackButtonsView(playButtonSize: 20, spacing: 15)
                                    .padding(3)
                                
                                if playerManager.musicApp.playbackSeekerEnabled {
                                    PlaybackPositionView()
                                        .frame(width: 155)
                                }
                            }
                            .padding(10)
                            .frame(width: 180)
                            .background(
                                VisualEffectView(material: .popover, blendingMode: .withinWindow)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .strokeBorder(.quaternary, lineWidth: 1)
                                    }
                            )
                            .cornerRadius(10)
                            .opacity(isShowingPlaybackControls ? 1 : 0)
                        }
                    }
                    
                    TrackDetailsView()
                        .padding(.horizontal, 5)
                }
            }
        }
        .padding(10)
        .overlay(
            NotificationView()
                .padding(.top, 20)
        )
        .background {
            BackgroundView(background: popoverBackground, yOffset: -20)
                .offset(y: -20) // To color the tip of the popover
                .frame(height: 300)
        }
        .onHover { _ in
            withAnimation(Constants.mainAnimation) {
                self.isShowingPlaybackControls.toggle()
            }
        }
        .frame(width: Constants.popoverWidth, height: Constants.compactPopoverHeight)
    }
}

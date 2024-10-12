//
//  CompactPopoverView.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/06/2024.
//

import SwiftUI

struct CompactPopoverView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @AppStorage("popoverBackground") var popoverBackground: BackgroundType = .albumArt
    @State private var isShowingPlaybackControls = false
    
    var body: some View {
        ZStack {
            if popoverBackground == .albumArt && playerManager.isRunning {
                Image(nsImage: playerManager.track.albumArt)
                    .resizable()
                VisualEffectView(material: .popover, blendingMode: .withinWindow)
            }
            
            if !playerManager.isRunning {
                Text("Please open \(playerManager.name) to use Tuneful")
                    .foregroundColor(.primary.opacity(Constants.Opacity.secondaryOpacity))
                    .font(.system(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack {
                    ZStack {
                        AlbumArtView(imageSize: 185)
            
                        AddToFavoritesView()
                            .opacity(isShowingPlaybackControls ? 1 : 0)
                            .offset(y: -30)
                        
                        VStack {
                            Spacer()
                                .frame(height: 90)
                            
                            VStack(alignment: .center) {
                                PlaybackButtonsView(playButtonSize: 22.5, spacing: 10)
                                
                                PlaybackPositionView()
                                    .frame(width: 155)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .frame(width: 170)
                            .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
                            .cornerRadius(10)
                            .opacity(isShowingPlaybackControls ? 1 : 0)
                        }
                    }
                    .offset(x: -1, y: -3)
                    
                    Button(action: playerManager.openMusicApp) {
                        VStack(alignment: .center) {
                            Text(playerManager.track.title)
                                .foregroundColor(.primary.opacity(Constants.Opacity.primaryOpacity))
                                .font(.system(size: 15, weight: .bold))
                                .lineLimit(1)
                            Text(playerManager.track.artist)
                                .foregroundColor(.primary.opacity(Constants.Opacity.primaryOpacity2))
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                        }
                    }
                    .pressButtonStyle()
                    .opacity(0.8)
                    .padding(.top, 5)
                    .frame(width: 180)
                }
            }
        }
        .overlay(
            NotificationView()
                .padding(.top, 15)
        )
        .frame(
            width: AppDelegate.popoverWidth,
            height: 260
        )
        .onHover { _ in
            withAnimation(.linear(duration: 0.2)) {
                self.isShowingPlaybackControls.toggle()
            }
        }
    }
}

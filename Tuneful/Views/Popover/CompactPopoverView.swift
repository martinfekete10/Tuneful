//
//  CompactPopoverView.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/06/2024.
//

import SwiftUI

struct CompactPopoverView: View {
    
    @EnvironmentObject var playerManager: PlayerManager
    @AppStorage("popoverBackground") var popoverBackground: BackgroundType = .transparent
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
                        Button(action: playerManager.openMusicApp) {
                            AlbumArtView(imageSize: 185)
                        }
                        .pressButtonStyle()
                        
                        VStack {
                            Spacer()
                                .frame(height: 90)
                            
                            VStack(alignment: .center) {
                                HStack(spacing: 10) {
                                    Button(action: playerManager.setShuffle){
                                        Image(systemName: "shuffle")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .animation(.easeInOut(duration: 2.0), value: 1)
                                            .font(playerManager.shuffleIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                                            .opacity(playerManager.shuffleContextEnabled ? 1.0 : 0.45)
                                    }
                                    .pressButtonStyle()
                                    .disabled(!playerManager.shuffleContextEnabled)
                                    
                                    Button(action: playerManager.previousTrack){
                                        Image(systemName: "backward.end.fill")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .animation(.easeInOut(duration: 2.0), value: 1)
                                    }
                                    .pressButtonStyle()
                                    
                                    PlayPauseButton(buttonSize: 25)
                                    
                                    Button(action: playerManager.nextTrack) {
                                        Image(systemName: "forward.end.fill")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .animation(.easeInOut(duration: 2.0), value: 1)
                                    }
                                    .pressButtonStyle()
                                    
                                    Button(action: playerManager.setRepeat){
                                        Image(systemName: "repeat")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .font(playerManager.repeatIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                                            .opacity(playerManager.repeatContextEnabled ? 1.0 : 0.45)
                                    }
                                    .pressButtonStyle()
                                    .disabled(!playerManager.repeatContextEnabled)
                                }
                                
                                PlaybackPositionView()
                                    .frame(width: 155)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .frame(width: 170)
                            .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
                            .cornerRadius(8)
                            .opacity(isShowingPlaybackControls ? 1 : 0)
                        }
                    }
                    
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
        .onHover { _ in
            withAnimation(.linear(duration: 0.1)) {
                self.isShowingPlaybackControls.toggle()
            }
        }
        .frame(
            width: AppDelegate.popoverWidth,
            height: 260
        )
    }
}

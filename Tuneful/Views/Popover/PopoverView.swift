//
//  PopoverView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/09/2023.
//

import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @AppStorage("popoverBackground") var popoverBackground: BackgroundType = .albumArt
    @State private var isShowingPlaybackControls = false
    
    var body: some View {
        ZStack {
            if popoverBackground == .albumArt && playerManager.isRunning {
                playerManager.track.albumArt
                    .resizable()
                VisualEffectView(material: .popover, blendingMode: .withinWindow)
            }
            
            if !playerManager.musicApp.isRunning() || playerManager.track.isEmpty() {
                Text("Please open \(playerManager.name) to use Tuneful")
                    .foregroundColor(.primary.opacity(Constants.Opacity.secondaryOpacity))
                    .font(.system(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        // Album art and add to favorites button
                        ZStack {
                            AlbumArtView(imageSize: 185)
                                .padding(.top, 12)
                            
                            AddToFavoritesView()
                                .opacity(isShowingPlaybackControls ? 1 : 0)
                        }
                        .onHover { _ in
                            withAnimation(.linear(duration: 0.1)) {
                                self.isShowingPlaybackControls.toggle()
                            }
                        }

                        // Track details
                        Button(action: playerManager.openMusicApp) {
                            VStack(alignment: .center) {
                                Text(playerManager.track.title)
                                    .foregroundColor(.primary.opacity(Constants.Opacity.primaryOpacity))
                                    .font(.system(size: 15, weight: .bold))
                                    .lineLimit(1)
                                Text(playerManager.track.artist)
                                    .foregroundColor(.primary.opacity(Constants.Opacity.primaryOpacity2))
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                            }
                            .frame(width: 180, height: 65, alignment: .center)
                            .opacity(0.8)
                        }
                        .pressButtonStyle()

                        if playerManager.musicApp.playbackSeekerEnabled {
                            PlaybackPositionView()
                        }
                        
                        PlaybackButtonsView(playButtonSize: 22.5, spacing: 17.5)
                            .padding(.vertical, 5)
                        
                        HStack {
                            Menu {
                                ForEach(playerManager.audioDevices) { audioDevice in
                                    Button {
                                        playerManager.setOutputDevice(audioDevice: audioDevice)
                                    } label: {
                                        if audioDevice == playerManager.audioDevices.first(where: { $0.isDefault(for: .output) }) {
                                            Text("✓ \(audioDevice.name)")
                                        } else {
                                            Text(audioDevice.name)
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "hifispeaker.fill")
                            }
                            .frame(width: 20, height: 20)
                            .menuIndicator(.hidden)
                            .menuStyle(.borderlessButton)
                            
                            VolumeControlView()
                            
 
                            Button(action: openSettings){
                                Image(systemName: "gear")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            }
                            .pressButtonStyle()
                        }
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 15)
                }
                .padding()
            }
        }
        .overlay(
            NotificationView()
                .padding(.top, 15)
        )
        .frame(
            width: AppDelegate.popoverWidth,
            height: playerManager.musicApp.playbackSeekerEnabled ? 370 : 350
        )
    }
    
    func openSettings() {
        NSApplication.shared.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
    }
}

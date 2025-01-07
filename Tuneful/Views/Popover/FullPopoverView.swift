//
//  PopoverView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/09/2023.
//

import SwiftUI
import Defaults

struct FullPopoverView: View {
    @EnvironmentObject private var playerManager: PlayerManager
    @State private var isShowingPlaybackControls = false
    
    @Default(.popoverBackground) private var popoverBackground
    @Default(.connectedApp) private var connectedApp
    
    var body: some View {
        ZStack {
            if !playerManager.musicApp.isRunning() || playerManager.track.isEmpty() {
                Text("Play something in \(playerManager.name) to use Tuneful")
                    .foregroundColor(.primary.opacity(Constants.Opacity.secondaryOpacity))
                    .font(.system(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack() {
                    ZStack {
                        AlbumArtView(imageSize: 190)
                        
                        AddToFavoritesView()
                            .opacity(isShowingPlaybackControls ? 1 : 0)
                    }
                    .onHover { _ in
                        withAnimation(Constants.mainAnimation) {
                            self.isShowingPlaybackControls.toggle()
                        }
                    }

                    TrackDetailsView()

                    if playerManager.musicApp.playbackSeekerEnabled {
                        PlaybackPositionView()
                    }
                    
                    PlaybackButtonsView(playButtonSize: 22.5, spacing: 17.5)
                    
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
                }
            }
        }
        .padding(10)
        .frame(width: Constants.popoverWidth, height: Constants.fullPopoverHeight)
        .overlay(
            NotificationView()
                .padding(.top, 20)
        )
        .background {
            if playerManager.musicApp.isRunning() && !playerManager.track.isEmpty() {
                BackgroundView(background: popoverBackground, yOffset: -60)
                    .offset(y: -20) // To color the tip of the popover
                    .frame(height: Constants.fullPopoverHeight + 40)
            }
        }
    }
    
    func openSettings() {
        NSApplication.shared.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
    }
}

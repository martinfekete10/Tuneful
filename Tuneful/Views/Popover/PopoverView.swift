//
//  PopoverView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/09/2023.
//

import SwiftUI

struct PopoverView: View {
    
    @AppStorage("popoverBackground") var popoverBackground: BackgroundType = .albumArt
    @EnvironmentObject var playerManager: PlayerManager
    
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
                VStack(spacing: 0) {
                    // Media details
                    VStack(spacing: 0) {
                        
                        Button(action: playerManager.openMusicApp) {
                            AlbumArtView(imageSize: 185)
                                .padding(.top, 12)
                        }
                        .pressButtonStyle()

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

                        PlaybackPositionView()

                        HStack(spacing: 15) {
                            Button(action: playerManager.setShuffle){
                                Image(systemName: "shuffle")
                                    .resizable()
                                    .frame(width: 17, height: 17)
                                    .animation(.easeInOut(duration: 2.0), value: 1)
                                    .font(playerManager.shuffleIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                                    .opacity(playerManager.shuffleContextEnabled ? 1.0 : 0.45)
                            }
                            .pressButtonStyle()
                            .disabled(!playerManager.shuffleContextEnabled)

                            Button(action: playerManager.previousTrack){
                                Image(systemName: "backward.end.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .animation(.easeInOut(duration: 2.0), value: 1)
                            }
                            .pressButtonStyle()

                            PlayPauseButton(buttonSize: 40)

                            Button(action: playerManager.nextTrack) {
                                Image(systemName: "forward.end.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .animation(.easeInOut(duration: 2.0), value: 1)
                            }
                            .pressButtonStyle()

                            Button(action: playerManager.setRepeat){
                                Image(systemName: "repeat")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .font(playerManager.repeatIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                                    .opacity(playerManager.repeatContextEnabled ? 1.0 : 0.45)
                            }
                            .pressButtonStyle()
                            .disabled(!playerManager.repeatContextEnabled)
                        }
                        .opacity(0.8)
                        
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
            height: 370
        )
    }
    
    func openSettings() {
        NSApplication.shared.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
    }
}

//
//  PopoverView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/09/2023.
//

import SwiftUI

struct PopoverView: View {
    
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    var body: some View {
        
        ZStack {
            if !contentViewModel.isRunning {
                Text("Please open \(contentViewModel.name) to use Tuneful")
                    .foregroundColor(.primary.opacity(Constants.Opacity.secondaryOpacity))
                    .font(.system(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    // Media details
                    VStack(spacing: 0) {
                        
                        AlbumArtView(imageSize: 180)
                            .padding(.top, 5)

                        // Track details
                        Button(action: contentViewModel.openMusicApp) {
                            VStack(alignment: .center) {
                                Text(contentViewModel.track.title)
                                    .foregroundColor(.primary.opacity(Constants.Opacity.primaryOpacity))
                                    .font(.system(size: 15, weight: .bold))
                                    .lineLimit(1)
                                Text(contentViewModel.track.artist)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    .foregroundColor(.primary.opacity(Constants.Opacity.primaryOpacity2))
                            }
                            .frame(width: 180, height: 65, alignment: .center)
                            .opacity(0.8)
                        }
                        .pressButtonStyle()

                        PlaybackPositionView()

                        HStack(spacing: 15) {
                            Button(action: contentViewModel.setShuffle){
                                Image(systemName: "shuffle")
                                    .resizable()
                                    .frame(width: 17, height: 17)
                                    .animation(.easeInOut(duration: 2.0), value: 1)
                                    .font(contentViewModel.shuffleIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                                    .opacity(contentViewModel.shuffleContextEnabled ? 1.0 : 0.45)
                            }
                            .pressButtonStyle()
                            .disabled(!contentViewModel.shuffleContextEnabled)

                            Button(action: contentViewModel.previousTrack){
                                Image(systemName: "backward.end.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .animation(.easeInOut(duration: 2.0), value: 1)
                            }
                            .pressButtonStyle()

                            PlayPauseButton(buttonSize: 40)

                            Button(action: contentViewModel.nextTrack) {
                                Image(systemName: "forward.end.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .animation(.easeInOut(duration: 2.0), value: 1)
                            }
                            .pressButtonStyle()

                            Button(action: contentViewModel.setRepeat){
                                Image(systemName: "repeat")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .font(contentViewModel.repeatIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                                    .opacity(contentViewModel.repeatContextEnabled ? 1.0 : 0.45)
                            }
                            .pressButtonStyle()
                            .disabled(!contentViewModel.repeatContextEnabled)
                        }
                        .opacity(0.8)
                        
                        HStack {
                            VolumeControlView()

                            Menu {
                                ForEach(contentViewModel.audioDevices) { audioDevice in
                                    Button {
                                        contentViewModel.setOutputDevice(audioDevice: audioDevice)
                                    } label: {
                                        if audioDevice == contentViewModel.audioDevices.first(where: { $0.isDefault(for: .output) }) {
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
                        }
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 15)
                }
                .padding()
            }
        }
        .overlay(NotificationView())
        .frame(
            width: AppDelegate.popoverWidth,
            height: AppDelegate.popoverHeight
        )
    }
}

//
//  Untitled.swift
//  Tuneful
//
//  Created by Martin Fekete on 29/09/2024.
//

import SwiftUI

struct PlaybackButtonsView: View {
    @EnvironmentObject var playerManager: PlayerManager
    
    var playButtonSize: CGFloat = 25
    var hideShuffleAndRepeat: Bool = false
    var spacing: CGFloat = 12.5
    
    var body: some View {
        HStack(spacing: spacing) {
            if !hideShuffleAndRepeat {
                if #available(macOS 14.0, *) {
                    HoverButton(icon: "shuffle", iconSize: playButtonSize * 0.6) {
                        playerManager.setShuffle()
                    }
                    .font(playerManager.shuffleIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                    .opacity(playerManager.shuffleContextEnabled ? 1.0 : 0.5)
                    .disabled(!playerManager.shuffleContextEnabled)
                } else {
                    Button(action: playerManager.setShuffle){
                        Image(systemName: "shuffle")
                            .resizable()
                            .frame(width: playButtonSize * 0.45, height: playButtonSize * 0.45)
                            .animation(.easeInOut(duration: 2.0), value: 1)
                            .font(playerManager.shuffleIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                            .opacity(playerManager.shuffleContextEnabled ? 1.0 : 0.5)
                    }
                    .pressButtonStyle()
                    .disabled(!playerManager.shuffleContextEnabled)
                }
            }

            if #available(macOS 14.0, *) {
                HoverButton(icon: "backward.fill", iconSize: playButtonSize) {
                    playerManager.previousTrack()
                }
            } else {
                Button(action: playerManager.previousTrack) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: playButtonSize * 0.5, height: playButtonSize * 0.5)
                        .animation(.easeInOut(duration: 2.0), value: 1)
                }
                .pressButtonStyle()
            }
            
            
            if #available(macOS 14.0, *) {
                HoverButton(icon: playerManager.isPlaying ? "pause.fill" : "play.fill", iconSize: playButtonSize) {
                    playerManager.togglePlayPause()
                }
            } else {
                PlayPauseButton(buttonSize: playButtonSize)
            }

            if #available(macOS 14.0, *) {
                HoverButton(icon: "forward.fill", iconSize: playButtonSize) {
                    playerManager.nextTrack()
                }
            } else {
                Button(action: playerManager.nextTrack) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: playButtonSize * 0.5, height: playButtonSize * 0.5)
                        .animation(.easeInOut(duration: 2.0), value: 1)
                }
                .pressButtonStyle()
            }

            if !hideShuffleAndRepeat {
                if #available(macOS 14.0, *) {
                    HoverButton(icon: "repeat", iconSize: playButtonSize * 0.6) {
                        playerManager.setRepeat()
                    }
                    .font(playerManager.repeatIsOn ? Font.title.weight(.bold) : Font.title.weight(.light))
                    .opacity(playerManager.repeatContextEnabled ? 1.0 : 0.45)
                    .disabled(!playerManager.repeatContextEnabled)
                } else {
                    Button(action: playerManager.setRepeat){
                        Image(systemName: "repeat")
                            .resizable()
                            .frame(width: playButtonSize * 0.45, height: playButtonSize * 0.5)
                            .font(playerManager.repeatIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                            .opacity(playerManager.repeatContextEnabled ? 1.0 : 0.45)
                    }
                    .pressButtonStyle()
                    .disabled(!playerManager.repeatContextEnabled)
                }
            }
        }
        .opacity(0.8)
    }
}

//
//  PlaybackButtonsView.swift
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
                HoverButton(icon: "shuffle", iconSize: playButtonSize * 0.75) {
                    playerManager.setShuffle()
                }
                .font(playerManager.shuffleIsOn ? Font.title.weight(.black) : Font.title.weight(.ultraLight))
                .opacity(playerManager.shuffleContextEnabled ? 1.0 : 0.5)
                .disabled(!playerManager.shuffleContextEnabled)
            }

            HoverButton(
                icon: playerManager.track.isPodcast ? "15.arrow.trianglehead.counterclockwise" : "backward.fill",
                iconSize: playButtonSize)
            {
                playerManager.previousTrack()
            }
            
            if #available(macOS 14.0, *) {
                HoverButton(icon: playerManager.isPlaying ? "pause.fill" : "play.fill", iconSize: playButtonSize) {
                    playerManager.togglePlayPause()
                }
            } else {
                PlayPauseButton(buttonSize: playButtonSize)
            }

            HoverButton(
                icon: playerManager.track.isPodcast ? "15.arrow.trianglehead.clockwise" : "forward.fill",
                iconSize: playButtonSize)
            {
                playerManager.nextTrack()
            }

            if !hideShuffleAndRepeat {
                HoverButton(icon: "repeat", iconSize: playButtonSize * 0.75) {
                    playerManager.setRepeat()
                }
                .font(playerManager.repeatIsOn ? Font.title.weight(.bold) : Font.title.weight(.light))
                .opacity(playerManager.repeatContextEnabled ? 1.0 : 0.45)
                .disabled(!playerManager.repeatContextEnabled)
            }
        }
        .opacity(0.8)
    }
}

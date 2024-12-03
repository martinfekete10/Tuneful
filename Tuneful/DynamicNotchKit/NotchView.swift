//
//  NotchView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

struct NotchView<Content>: View where Content: View {
    @ObservedObject var dynamicNotch: DynamicNotch<Content>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(width: dynamicNotch.notchWidth, height: dynamicNotch.notchHeight)
                    
                    if !dynamicNotch.isMouseInside && dynamicNotch.isNotificationVisible {
                        NotchInfoView(playerManager: dynamicNotch.playerManager, minimumNotchWidth: dynamicNotch.notchWidth)
                            .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 15) }
                            .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: 15) }
                            .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: 15) }
                            .blur(radius: dynamicNotch.isVisible ? 0 : 10)
                            .scaleEffect(dynamicNotch.isVisible ? 1 : 0.8)
                            .offset(y: dynamicNotch.isVisible ? 0 : 5)
                            .padding(.horizontal, 15) // Small corner radius of the TOP of the notch
                            .transition(.blur.animation(.smooth))
                    }
                    
                    if dynamicNotch.isMouseInside {
                        NotchPlayerView(playerManager: dynamicNotch.playerManager)
                            .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 15) }
                            .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: 15) }
                            .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: 15) }
                            .blur(radius: dynamicNotch.isVisible ? 0 : 10)
                            .scaleEffect(dynamicNotch.isVisible ? 1 : 0.8)
                            .offset(y: dynamicNotch.isVisible ? 0 : 5)
                            .padding(.horizontal, 15) // Small corner radius of the TOP of the notch
                            .transition(.blur.animation(.smooth))
                    }
                }
                .fixedSize()
                .frame(minWidth: dynamicNotch.notchWidth)
                .onHover { hovering in
                    withAnimation(dynamicNotch.animation) {
                        dynamicNotch.isMouseInside = hovering
                        dynamicNotch.isVisible = hovering
                    }
                }
                .onChange(of: dynamicNotch.isMouseInside) { isMouseInside in
                    if isMouseInside {
                        dynamicNotch.playerManager.startTimer()
                    } else {
                        dynamicNotch.playerManager.stopTimer()
                    }
                }
                .background {
                    Rectangle()
                        .foregroundStyle(.black)
                        .padding(-50) // The opening/closing animation can overshoot, so this makes sure that it's still black
                }
                .contextMenu {
                    Button(
                        action: { NSApplication.shared.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil) },
                        label: { Text("Settings...") }
                    )
                }
                .mask {
                    GeometryReader { _ in // This helps with positioning everything
                        HStack {
                            Spacer(minLength: 0)
                            NotchShape(cornerRadius: dynamicNotch.isVisible ? 20 : nil)
                                .frame(
                                    width: dynamicNotch.isVisible ? nil : dynamicNotch.notchWidth,
                                    height: dynamicNotch.isVisible ? nil : dynamicNotch.notchHeight
                                )
                            Spacer(minLength: 0)
                        }
                    }
                }
                .shadow(color: .black.opacity(0.6), radius: dynamicNotch.isVisible ? 10 : 0)
                .animation(dynamicNotch.animation, value: dynamicNotch.contentID)
                
                Spacer()
            }
            Spacer()
        }
    }
}

struct NotchInfoView: View {
    @ObservedObject private var playerManager: PlayerManager
    var minimumNotchWidth: Double

    init(playerManager: PlayerManager, minimumNotchWidth: Double) {
        self.playerManager = playerManager
        self.minimumNotchWidth = minimumNotchWidth
    }
    
    public var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .center, spacing: 8) {
                playerManager.track.albumArt
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .cornerRadius(5)
                Text(playerManager.track.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(playerManager.track.artist)
                    .foregroundStyle(.secondary)
                    .font(.headline)
                    .lineLimit(1)
            }
        }
        .frame(minWidth: minimumNotchWidth)
    }
}

struct NotchPlayerView: View {
    @ObservedObject private var playerManager: PlayerManager

    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AlbumArtView(imageSize: 80)
                .environmentObject(playerManager)
            
            VStack(alignment: .center) {
                Text(playerManager.track.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(playerManager.track.artist)
                    .foregroundStyle(.secondary)
                    .font(.headline)
                    .lineLimit(1)
                PlaybackButtonsView(playButtonSize: 20)
                    .environmentObject(playerManager)
                PlaybackPositionView(sliderHeight: 6, inline: true)
                    .environmentObject(playerManager)
            }
        }
        .frame(width: 350)
    }
}

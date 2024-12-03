//
//  NotchlessView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

struct NotchlessView<Content>: View where Content: View {
    @ObservedObject var dynamicNotch: DynamicNotch<Content>
    @State var windowHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Spacer(minLength: 20)
                    
                    NotchlessInfoView(playerManager: dynamicNotch.playerManager)
                        .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 10) }
                        .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 10) }
                        .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: 13) }
                        .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: 13) }
                        .transition(.blur.animation(.smooth))
                        .fixedSize()
                    
                    if dynamicNotch.isMouseInside {
                        NotchlessPlayerView(playerManager: dynamicNotch.playerManager)
                    }
                }
                .fixedSize()
                .onHover { hovering in
                    withAnimation(dynamicNotch.animation) {
                        dynamicNotch.isVisible = hovering
                        dynamicNotch.isMouseInside = hovering
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
                    VisualEffectView(material: .popover, blendingMode: .behindWindow)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(.quaternary, lineWidth: 1)
                        }
                }
                .contextMenu {
                    Button(
                        action: { NSApplication.shared.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil) },
                        label: { Text("Settings...") }
                    )
                }
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .black.opacity(0.5), radius: dynamicNotch.isVisible ? 10 : 0)
                .padding(5)
                .background {
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                windowHeight = geo.size.height // This makes sure that the floating window FULLY slides off before disappearing
                            }
                    }
                }
                .offset(y: dynamicNotch.isVisible ? dynamicNotch.notchHeight - 50 : -windowHeight + 7)
                .animation(dynamicNotch.animation, value: dynamicNotch.contentID)
                .opacity(dynamicNotch.isVisible ? 1 : 0.025)

                Spacer()
            }
            
            Spacer()
        }
    }
}

struct NotchlessInfoView: View {
    @ObservedObject private var playerManager: PlayerManager

    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            AlbumArtView(imageSize: 50)
                .environmentObject(playerManager)
            
            VStack(alignment: .leading) {
                Text(playerManager.track.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(playerManager.track.artist)
                    .foregroundStyle(.secondary)
                    .font(.headline)
                    .lineLimit(1)
            }
        }
        .onTapGesture {
            playerManager.openMusicApp()
        }
        .frame(height: 50)
        .frame(maxWidth: 250)
    }
}

struct NotchlessPlayerView: View {
    @ObservedObject private var playerManager: PlayerManager

    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
    }
    
    public var body: some View {
        VStack {
            PlaybackButtonsView(playButtonSize: 20, spacing: 20)
                .environmentObject(playerManager)
                .padding(.bottom, 5)
            PlaybackPositionView(sliderHeight: 6, inline: true)
                .environmentObject(playerManager)
        }
        .frame(width: 250)
        .padding(.bottom, 15)
        .padding(.horizontal, 15)
    }
}

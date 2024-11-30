//
//  DynamicNotchInfoWindow.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

internal final class DynamicNotchInfoPublisher: ObservableObject {
    @Published var icon: Image?
    @Published var iconColor: Color
    @Published var title: String
    @Published var description: String?

    init(icon: Image?, iconColor: Color, title: String, description: String? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
    }

    @MainActor
    func publish(icon: Image?, iconColor: Color, title: String, description: String?) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
    }
}

public class DynamicNotchInfo {
    @Published var playerManager: PlayerManager
    private var internalDynamicNotch: DynamicNotch<InfoView>

    public init(contentID: UUID = .init(), style: DynamicNotch<InfoView>.Style = .auto, playerManager: PlayerManager) {
        self.playerManager = playerManager
        internalDynamicNotch = DynamicNotch(contentID: contentID, style: style, playerManager: playerManager) {
            InfoView(playerManager: playerManager)
        }
    }
    
    public func updateNotchWidth(isPlaying: Bool) {
        internalDynamicNotch.updateNotchWidth(isPlaying: isPlaying)
    }
    
    public func refreshContent() {
        internalDynamicNotch.refreshContent()
    }

    public func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) {
        internalDynamicNotch.show(on: screen, for: time)
    }

    public func hide() {
        internalDynamicNotch.hide()
    }

    public func toggle() {
        internalDynamicNotch.toggle()
    }
}

public extension DynamicNotchInfo {
    struct InfoView: View {
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
                    Text(playerManager.track.artist)
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                        .opacity(1)
                }
                
                Spacer(minLength: 0)
            }
            .frame(height: 50)
            .frame(maxWidth: 250)
            .tapAnimation {
                playerManager.openMusicApp()
            }
        }
    }
}

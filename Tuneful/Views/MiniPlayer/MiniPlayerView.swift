//
//  MiniPlayerView.swift
//  Tuneful
//
//  Created by Martin Fekete on 22/12/2024.
//

import SwiftUI
import Defaults

struct MiniPlayerView: View {
    @EnvironmentObject var playerManager: PlayerManager
    
    @Default(.miniPlayerType) private var miniPlayerType
    @Default(.miniPlayerScaleFactor) private var miniPlayerScaleFactor
    @Default(.miniPlayerBackground) private var miniPlayerBackground
    
    private var imageSize: CGFloat = 140.0
    
    var body: some View {
        ZStack {
            if !playerManager.isRunning || playerManager.track.isEmpty() {
                Text("Please open \(playerManager.name) to use Tuneful")
                    .foregroundColor(.primary.opacity(0.4))
                    .font(.system(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(15)
                    .padding(.bottom, 20)
            } else {
                switch miniPlayerType {
                case .horizontal:
                    HorizontalMiniPlayerView()
                case .vertical:
                    VerticalMiniPlayerView()
                case .minimal:
                    CompactMiniPlayerView()
                }
            }
        }
        .padding(10 * miniPlayerScaleFactor.rawValue)
        .overlay(
            NotificationView()
        )
        .background(
            ZStack {
                VisualEffectView(material: .popover, blendingMode: .behindWindow)
                BackgroundView(
                    background: miniPlayerBackground,
                    albumArtSize: imageSize * miniPlayerScaleFactor.rawValue,
                    yOffset: -80 * miniPlayerScaleFactor.rawValue
                )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1.5)
            }
        )
    }
}

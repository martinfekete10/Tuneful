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
    
    @Default(.miniPlayerScaleFactor) private var miniPlayerScaleFactor
    @Default(.miniPlayerBackground) private var miniPlayerBackground
    @Default(.miniPlayerType) private var miniPlayerType
    
    private var imageSize: CGFloat = 140.0
    
    init(miniPlayerType: MiniPlayerType? = nil) {
        self.miniPlayerType = miniPlayerType ?? Defaults[.miniPlayerType]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
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
                                .transition(.blur.animation(.bouncy))
                        case .vertical:
                            VerticalMiniPlayerView()
                                .transition(.blur.animation(.bouncy))
                        case .minimal:
                            CompactMiniPlayerView()
                                .transition(.blur.animation(.bouncy))
                        }
                    }
                }
                .fixedSize()
                .clipShape(.rect(cornerRadius: 12.5))
                .padding(10 * miniPlayerScaleFactor.rawValue)
                .overlay(
                    NotificationView()
                )
                .background(
                    ZStack {
                        VisualEffectView(material: .popover, blendingMode: .behindWindow)
                        getBackgroundView()
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12.5, style: .continuous)
                            .strokeBorder(.quaternary, lineWidth: 1.5)
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    func getBackgroundView() -> some View {
        switch miniPlayerType {
        case .minimal:
            BackgroundView(
                background: miniPlayerBackground,
                albumArtSize: imageSize * miniPlayerScaleFactor.rawValue * 0.9
            )
        case .horizontal:
            BackgroundView(
                background: miniPlayerBackground,
                albumArtSize: imageSize * miniPlayerScaleFactor.rawValue,
                xOffset: -75 * miniPlayerScaleFactor.rawValue
            )
        case .vertical:
            BackgroundView(
                background: miniPlayerBackground,
                albumArtSize: imageSize * miniPlayerScaleFactor.rawValue,
                yOffset: -45 * miniPlayerScaleFactor.rawValue
            )
        }
    }
}

//
//  AlbumArtView.swift
//  Tuneful
//
//  Created by Martin Fekete on 24/09/2023.
//

import SwiftUI

struct AlbumArtView: View {
    
    @EnvironmentObject var contentViewModel: ContentViewModel
    @State private var isShowingPlaybackControls = false
    
    private var imageSize: CGFloat
    
    init(imageSize: CGFloat = 180) {
        self.imageSize = imageSize
    }
    
    var body: some View {
        ZStack {
            Button(action: contentViewModel.openMusicApp) {
                Image(nsImage: contentViewModel.track.albumArt)
                    .resizable()
                    .scaledToFill()
                    .frame(width: self.imageSize, height: self.imageSize)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .pressButtonStyle()
            
            if contentViewModel.isLikeAuthorized() {
                VStack {
                    // Like button
                    HStack(spacing: 6) {
                        Button {
                            contentViewModel.toggleLoveTrack()
                        } label: {
                            Image(systemName: contentViewModel.isLoved ? "heart.fill" : "heart")
                                .font(.system(size: 14))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        .pressButtonStyle()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
                    .cornerRadius(100)
                    .opacity(isShowingPlaybackControls ? 1 : 0)
                }
            }
        }
        .onHover { _ in
            withAnimation(.linear(duration: 0.1)) {
                self.isShowingPlaybackControls.toggle()
            }
        }
    }
    
    func test() {
        NSApplication.shared.sendAction(#selector(AppDelegate.showPreferences), to: nil, from: nil)
    }
}

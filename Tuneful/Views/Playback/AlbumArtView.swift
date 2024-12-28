//
//  AlbumArtView.swift
//  Tuneful
//
//  Created by Martin Fekete on 24/09/2023.
//

import SwiftUI

struct AlbumArtView: View {
    @EnvironmentObject var playerManager: PlayerManager
    
    var imageSize: CGFloat = 180
    
    var body: some View {
        ZStack {
            playerManager.track.albumArt
                .resizable()
                .frame(width: self.imageSize, height: self.imageSize)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                .tapAnimation(scale: 1.2, duration: 0.4) {
                    self.playerManager.openMusicApp()
                }
        }
    }
}

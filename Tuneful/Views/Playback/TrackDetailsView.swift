//
//  TrackDetailsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 28/12/2024.
//

import SwiftUI

struct TrackDetailsView: View {
    @EnvironmentObject var playerManager: PlayerManager
    
    var body: some View {
        Button(action: playerManager.openMusicApp) {
            VStack(alignment: .center) {
                Text(playerManager.track.title)
                    .foregroundColor(.primary.opacity(Constants.Opacity.primaryOpacity))
                    .font(.system(size: 15, weight: .bold))
                    .lineLimit(1)
                Text(playerManager.track.artist)
                    .foregroundColor(.primary.opacity(Constants.Opacity.primaryOpacity2))
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .opacity(0.8)
        }
        .pressButtonStyle()
    }
}

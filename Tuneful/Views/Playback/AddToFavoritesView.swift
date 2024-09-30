//
//  AddToFavoritesView.swift
//  Tuneful
//
//  Created by Martin Fekete on 29/09/2024.
//

import SwiftUI

struct AddToFavoritesView: View  {
    @EnvironmentObject var playerManager: PlayerManager
    
    var body: some View {
        if playerManager.isLikeAuthorized() {
            VStack {
                HStack(spacing: 6) {
                    Button {
                        playerManager.toggleLoveTrack()
                    } label: {
                        Image(systemName: playerManager.isLoved ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(.primary.opacity(0.8))
                    }
                    .pressButtonStyle()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
                .cornerRadius(100)
            }
        }
    }
}

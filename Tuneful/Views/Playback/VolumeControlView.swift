//
//  VolumeControlView.swift
//  Tuneful
//
//  Created by Martin Fekete on 29/10/2023.
//

import Foundation
import Combine
import SwiftUI
import ISSoundAdditions

struct VolumeControlView: View {
    
    @EnvironmentObject var playerManager: PlayerManager
    @AppStorage("showPlayerWindow") var showPlayerWindow: Bool = true
    
    let volumeIconSize = CGFloat(12)
    
    var body: some View {
        HStack(spacing: 5) {
            Button(action: playerManager.decreaseVolume) {
                Image(systemName: "speaker.wave.1.fill")
                    .resizable()
                    .frame(width: volumeIconSize, height: volumeIconSize)
                    .animation(.easeInOut(duration: 2.0), value: 1)
            }
            .pressButtonStyle()
            
            CustomSliderView(
                value: $playerManager.volume,
                isDragging: $playerManager.isDraggingSoundVolumeSlider,
                range: 0...100,
                sliderHeight: 5
            )
            
            Button(action: playerManager.increaseVolume) {
                Image(systemName: "speaker.wave.2.fill")
                    .resizable()
                    .frame(width: volumeIconSize, height: volumeIconSize)
                    .animation(.easeInOut(duration: 2.0), value: 1)
            }
            .pressButtonStyle()
        }
        .onChange(of: playerManager.volume, perform: { newVolume in
            playerManager.setVolume(newVolume: Int(newVolume))
        })
        .padding(.leading, 2)
        .padding(.trailing, 2)
    }
}

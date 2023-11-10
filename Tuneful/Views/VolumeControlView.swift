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
    
    @EnvironmentObject var contentViewModel: ContentViewModel
    @AppStorage("showPlayerWindow") var showPlayerWindow: Bool = true
    
    let volumeIconSize = CGFloat(12)
    
    var body: some View {
        HStack(spacing: 5) {
            Button(action: contentViewModel.decreaseVolume) {
                Image(systemName: "speaker.wave.1.fill")
                    .resizable()
                    .frame(width: volumeIconSize, height: volumeIconSize)
                    .animation(.easeInOut(duration: 2.0), value: 1)
            }
            .pressButtonStyle()
            
            CustomSliderView(
                value: $contentViewModel.volume,
                isDragging: $contentViewModel.isDraggingSoundVolumeSlider,
                range: 0...1,
                knobDiameter: 5,
                knobColor: .white,
                knobScaleEffectMagnitude: 1.5,
                knobAnimation: .linear(duration: 0.15),
                leadingRectangleColor: .playbackPositionLeadingRectangle
            )
            
            Button(action: contentViewModel.increaseVolume) {
                Image(systemName: "speaker.wave.2.fill")
                    .resizable()
                    .frame(width: volumeIconSize, height: volumeIconSize)
                    .animation(.easeInOut(duration: 2.0), value: 1)
            }
            .pressButtonStyle()
        }
        .onChange(of: contentViewModel.volume, perform: { newVolume in
            contentViewModel.setVolume(newVolume: newVolume)
        })
        .padding(.leading, 2)
        .padding(.trailing, 2)
    }
}

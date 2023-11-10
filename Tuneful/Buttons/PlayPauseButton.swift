//
//  PlayPauseButton.swift
//  Tuneful
//
//  Created by Martin Fekete on 08/08/2023.
//

import SwiftUI

struct PlayPauseButton: View {
    
    @EnvironmentObject var contentViewModel: ContentViewModel
    @State private var transparency: Double = 0.0
    
    let buttonSize: CGFloat
    
    init(buttonSize: CGFloat = 30) {
        self.buttonSize = buttonSize
    }
    
    var body: some View {
        Button(action: {
            contentViewModel.togglePlayPause()
            transparency = 0.6
            withAnimation(.easeOut(duration: 0.2)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    transparency = 0.0
                }
            }
        }) {
            ZStack {
                Image(systemName: "pause.circle.fill")
                    .resizable()
                    .frame(width: self.buttonSize, height: self.buttonSize)
                    .scaleEffect(contentViewModel.isPlaying ? 1.01 : 0.09)
                    .opacity(contentViewModel.isPlaying ? 1.01 : 0.09)
                    .animation(.interpolatingSpring(stiffness: 150, damping: 20), value: contentViewModel.isPlaying)
                
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: self.buttonSize, height: self.buttonSize)
                    .scaleEffect(contentViewModel.isPlaying ? 0.09 : 1.01)
                    .opacity(contentViewModel.isPlaying ? 0.09 : 1.01)
                    .animation(.interpolatingSpring(stiffness: 150, damping: 20), value: contentViewModel.isPlaying)
            }
        }
        .buttonStyle(MusicControlButtonStyle())
    }
}

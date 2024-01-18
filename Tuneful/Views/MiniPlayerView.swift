//
//  ContentView.swift
//  Tuneful
//
//  Created by Martin Fekete on 27/07/2023.
//

import SwiftUI
import MediaPlayer

struct MiniPlayerView: View {
    
    @AppStorage("miniPlayerBackground") var miniPlayerBackground: BackgroundType = .albumArt
    
    @EnvironmentObject var playerManager: PlayerManager

    var body: some View {
        if !playerManager.isRunning {
            Text("Please open \(playerManager.name) to use Tuneful")
                .foregroundColor(.primary.opacity(0.4))
                .font(.system(size: 14, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
                .padding(15)
                .padding(.bottom, 20)
        } else {
            ZStack {
                if miniPlayerBackground == .albumArt && playerManager.isRunning {
                    Image(nsImage: playerManager.track.albumArt)
                        .resizable()
                        .scaledToFill()
                    
                    VisualEffectView(material: .popover, blendingMode: .withinWindow)
                }
                
                HStack(spacing: 0) {
                    AlbumArtView(imageSize: 110)
                        .padding()
                    
                    VStack(spacing: 7) {
                        Button(action: playerManager.openMusicApp) {
                            VStack {
                                Text(playerManager.track.title)
                                    .font(.body)
                                    .bold()
                                    .lineLimit(1)
                                
                                Text(playerManager.track.artist)
                                    .font(.body)
                                    .lineLimit(1)
                            }
                        }
                        .pressButtonStyle()
                        
                        PlaybackPositionView()
                        
                        HStack(spacing: 10) {
                            
                            Button(action: playerManager.previousTrack){
                                Image(systemName: "backward.end.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .animation(.easeInOut(duration: 2.0), value: 1)
                            }
                            .pressButtonStyle()
                            
                            PlayPauseButton(buttonSize: 35)
                            
                            Button(action: playerManager.nextTrack) {
                                Image(systemName: "forward.end.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .animation(.easeInOut(duration: 2.0), value: 1)
                            }
                            .pressButtonStyle()
                        }
                    }
                    .padding()
                    .opacity(0.8)
                }
            }
            .frame(width: 300, height: 120)
            .position(CGPoint(x: 150, y: 71))
            .edgesIgnoringSafeArea(.all)
            .overlay(
                NotificationView()
            )
            .if(miniPlayerBackground == .transparent) { view in
                view.background(VisualEffectView(material: .underWindowBackground, blendingMode: .withinWindow))
            }
        }
    }
}

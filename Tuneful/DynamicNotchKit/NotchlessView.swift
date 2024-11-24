//
//  NotchlessView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

struct NotchlessView<Content>: View where Content: View {
    @ObservedObject var dynamicNotch: DynamicNotch<Content>
    @State var windowHeight: CGFloat = 0
    @State var title: String = ""
    @State var artist: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    dynamicNotch.content()
                        .id(dynamicNotch.contentID)
                        .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 10) }
                        .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 10) }
                        .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: 13) }
                        .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: 13) }
                        .transition(.blur.animation(.smooth))
                        .fixedSize()
                    
                    if dynamicNotch.isMouseInside {
                        VStack {
                            PlaybackButtonsView(playButtonSize: 20)
                                .environmentObject(dynamicNotch.playerManager)
                        }
                        .frame(width: dynamicNotch.notchWidth * 0.75)
                        .padding(.bottom, 15)
                    }
                }
                .onHover { hovering in
                    if !dynamicNotch.isVisible {
                        return
                    }
                    withAnimation(dynamicNotch.animation) {
                        dynamicNotch.isMouseInside = hovering
                    }
                }
                .background {
                    VisualEffectView(material: .popover, blendingMode: .behindWindow)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(.quaternary, lineWidth: 1)
                        }
                }
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .black.opacity(0.5), radius: dynamicNotch.isVisible ? 10 : 0)
                .padding(5)
                .background {
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                windowHeight = geo.size.height // This makes sure that the floating window FULLY slides off before disappearing
                            }
                    }
                }
                .offset(y: dynamicNotch.isVisible ? dynamicNotch.notchHeight : -windowHeight)
                .animation(dynamicNotch.animation, value: dynamicNotch.contentID)

                Spacer()
            }
            Spacer()
        }
    }
}

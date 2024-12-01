//
//  HoverButton.swift
//  Tuneful
//
//  Created by Kraigo: https://github.com/TheBoredTeam/boring.notch
//  Modified by Martin Fekete
//

import SwiftUI

struct HoverButton: View {
    var icon: String
    var iconSize: CGFloat = 60
    var action: () -> Void
    
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .frame(width: iconSize, height: iconSize)
                .overlay {
                    Capsule()
                        .fill(isHovering ? Color.gray.opacity(0.3) : .clear)
                        .frame(width: iconSize * 1.75, height: iconSize * 1.75)
                        .overlay {
                            if #available(macOS 14.0, *) {
                                Image(systemName: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: iconSize, height: iconSize)
                                    .contentTransition(.symbolEffect)
                            } else {
                                Image(systemName: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: iconSize, height: iconSize)
                                    .contentTransition(.opacity)
                            }
                        }
                }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.smooth(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

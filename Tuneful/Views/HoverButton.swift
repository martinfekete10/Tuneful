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
                .frame(width: iconSize * 1.1, height: iconSize * 1.1)
                .overlay {
                    if #available(macOS 14.0, *) {
                        Image(systemName: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: isHovering ? iconSize * 1.1 : iconSize, height: isHovering ? iconSize * 1.1 : iconSize)
                            .contentTransition(.symbolEffect)
                    } else {
                        Image(systemName: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: isHovering ? iconSize * 1.1 : iconSize, height: isHovering ? iconSize * 1.1 : iconSize)
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

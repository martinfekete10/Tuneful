//
//  NotchView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

struct NotchView<Content>: View where Content: View {
    @ObservedObject var dynamicNotch: DynamicNotch<Content>

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(width: dynamicNotch.notchWidth + 20, height: dynamicNotch.notchHeight)
                    // We add an extra 20 here because the corner radius of the top increases when shown.
                    // (the remaining 10 has already been accounted for in refreshNotchSize)

                    dynamicNotch.content()
                        .id(dynamicNotch.contentID)
                        .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 15) }
                        .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: 15) }
                        .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: 15) }

                        .blur(radius: dynamicNotch.isVisible ? 0 : 10)
                        .scaleEffect(dynamicNotch.isVisible ? 1 : 0.8)
                        .offset(y: dynamicNotch.isVisible ? 0 : 5)
                        .padding(.horizontal, 15) // Small corner radius of the TOP of the notch
                        .transition(.blur.animation(.smooth))
                }
                .fixedSize()
                .frame(minWidth: dynamicNotch.notchWidth)
                .onHover { hovering in
                    dynamicNotch.isMouseInside = hovering
                }
                .background {
                    Rectangle()
                        .foregroundStyle(.black)
                        .padding(-50) // The opening/closing animation can overshoot, so this makes sure that it's still black
                }
                .mask {
                    GeometryReader { _ in // This helps with positioning everything
                        HStack {
                            Spacer(minLength: 0)
                            NotchShape(cornerRadius: dynamicNotch.isVisible ? 20 : nil)
                                .frame(
                                    width: dynamicNotch.isVisible ? nil : dynamicNotch.notchWidth,
                                    height: dynamicNotch.isVisible ? nil : dynamicNotch.notchHeight
                                )
                            Spacer(minLength: 0)
                        }
                    }
                }
                .shadow(color: .black.opacity(0.5), radius: dynamicNotch.isVisible ? 10 : 0)
                .animation(dynamicNotch.animation, value: dynamicNotch.contentID)

                Spacer()
            }
            Spacer()
        }
    }
}

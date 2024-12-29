//
//  LuminareBackgroundEffect.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public struct LuminareBackgroundEffect: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background {
                VisualEffectView(material: .menu, blendingMode: .behindWindow)
                    .edgesIgnoringSafeArea(.top)
                    .allowsHitTesting(false)
            }
    }
}

public extension View {
    func luminareBackground() -> some View {
        modifier(LuminareBackgroundEffect())
    }
}

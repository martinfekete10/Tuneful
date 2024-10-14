//
//  TapAnimationModifier.swift
//  Tuneful
//
//  Created by Martin Fekete on 14/10/2024.
//

import SwiftUI

struct TapAnimationModifier: ViewModifier {
    @State private var isTapped: Bool = false

    let scaleAmount: CGFloat
    let duration: Double
    let onTap: () -> Void

    func body(content: Content) -> some View {
        content
            .scaleEffect(isTapped ? scaleAmount : 1.0)
            .animation(.timingCurve(0.16, 1, 0.3, 1, duration: duration), value: isTapped)
            .onTapGesture {
                isTapped.toggle()
                onTap()
            }
            .onChange(of: isTapped) { tapped in
                if tapped {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isTapped = false
                    }
                }
            }
    }
}

extension View {
    func tapAnimation(scale: CGFloat = 1.075, duration: Double = 0.5, onTap: @escaping () -> Void) -> some View {
        self.modifier(TapAnimationModifier(scaleAmount: scale, duration: duration, onTap: onTap))
    }
}

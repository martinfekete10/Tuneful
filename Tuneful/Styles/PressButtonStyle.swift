//
//  PressButtonStyle.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/08/2023.
//

import Foundation
import SwiftUI

struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? CGFloat(0.92) : 1.0)
    }
}

extension Button {
    func pressButtonStyle() -> some View {
        self.buttonStyle(PressButtonStyle())
    }
}

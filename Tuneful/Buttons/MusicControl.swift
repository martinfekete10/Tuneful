//
//  MusicControl.swift
//  Tuneful
//
//  Created by Martin Fekete on 08/08/2023.
//

import Foundation
import SwiftUI

struct MusicControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .buttonStyle(PlainButtonStyle())
    }
}

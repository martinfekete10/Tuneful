//
//  LuminareConstants.swift
//  Tuneful
//
//  Created by Martin Fekete on 29/12/2024.
//

import SwiftUI

public enum LuminareConstants {
    public static var tint: () -> Color = { .accentColor }
    public static var animation: Animation = .smooth(duration: 0.2)
    public static var fastAnimation: Animation = .easeOut(duration: 0.1)
}

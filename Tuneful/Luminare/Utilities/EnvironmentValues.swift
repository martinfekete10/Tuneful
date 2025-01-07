//
//  EnvironmentValues.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - TintColor

// Currently, it is impossible to read the .tint(Color) modifier on a view.
// This is a custom environement value as an alternative implementation of it.
public struct TintColorEnvironmentKey: EnvironmentKey {
    public static var defaultValue: () -> Color = { .accentColor }
}

public extension EnvironmentValues {
    var tintColor: () -> Color {
        get { self[TintColorEnvironmentKey.self] }
        set { self[TintColorEnvironmentKey.self] = newValue }
    }
}

// MARK: - HoveringOverLuminareItem

public struct HoveringOverLuminareItem: EnvironmentKey {
    public static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    var hoveringOverLuminareItem: Bool {
        get { self[HoveringOverLuminareItem.self] }
        set { self[HoveringOverLuminareItem.self] = newValue }
    }
}

// MARK: - ClickedOutside

public struct LuminareWindowKey: EnvironmentKey {
    public static let defaultValue: NSWindow? = nil
}

public extension EnvironmentValues {
    var luminareWindow: NSWindow? {
        get { self[LuminareWindowKey.self] }
        set { self[LuminareWindowKey.self] = newValue }
    }
}

// MARK: - ClickedOutside (Private)

struct ClickedOutsideFlagKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var clickedOutsideFlag: Bool {
        get { self[ClickedOutsideFlagKey.self] }
        set { self[ClickedOutsideFlagKey.self] = newValue }
    }
}

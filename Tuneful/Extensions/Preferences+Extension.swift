//
//  Preferences+Extension.swift
//  Tuneful
//
//  Created by Martin Fekete on 11/01/2023.
//

import SwiftUI
import Settings
import enum Settings.Settings

extension Settings.PaneIdentifier {
    static let general = Self("general")
    static let appearance = Self("appearance")
    static let about = Self("about")
}

public extension SettingsWindowController {
  override func keyDown(with event: NSEvent) {
    if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command, let key = event.charactersIgnoringModifiers {
      if key == "w" {
        self.close()
      }
    }
  }
}

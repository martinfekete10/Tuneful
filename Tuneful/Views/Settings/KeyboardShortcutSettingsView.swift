//
//  KeyboardShortcutSettings.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/01/2024.
//

import SwiftUI
import Settings
import KeyboardShortcuts
import Luminare

struct KeyboardShortcutsSettingsView: View {
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection {
                    Form {
                        KeyboardShortcuts.Recorder("Play/pause", name: .playPause)
                        KeyboardShortcuts.Recorder("Next track", name: .nextTrack)
                        KeyboardShortcuts.Recorder("Previous track", name: .previousTrack)
                        KeyboardShortcuts.Recorder("Show/hide mini player", name: .showMiniPlayer)
                        KeyboardShortcuts.Recorder("Switch music player", name: .changeMusicPlayer)
                        KeyboardShortcuts.Recorder("Show/hide menu bar player", name: .toggleMenuBarItemVisibility)
                        KeyboardShortcuts.Recorder("Show/hide popover", name: .togglePopover)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    KeyboardShortcutsSettingsView()
}

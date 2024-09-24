//
//  KeyboardShortcutSettings.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/01/2024.
//

import SwiftUI
import Settings
import KeyboardShortcuts

struct KeyboardShortcutsSettingsView: View {
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                VStack(alignment: .center, content: {
                    Form {
                        KeyboardShortcuts.Recorder("Play/pause:", name: .playPause)
                        KeyboardShortcuts.Recorder("Next track:", name: .nextTrack)
                        KeyboardShortcuts.Recorder("Previous track:", name: .previousTrack)
                        KeyboardShortcuts.Recorder("Toggle mini player:", name: .showMiniPlayer)
                        KeyboardShortcuts.Recorder("Switch music player:", name: .changeMusicPlayer)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                })
            }
        }
    }
}

#Preview {
    KeyboardShortcutsSettingsView()
}

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
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                })
            }
        }
    }
}

struct KeyboardShortcutsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardShortcutsSettingsView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

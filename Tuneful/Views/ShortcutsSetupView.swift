//
//  ShortcutsSetupView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/01/2024.
//

import SwiftUI
import KeyboardShortcuts

struct ShortcutsSetupView: View {
    
    @AppStorage("viewedShortcutsSetup") var viewedShortcutsSetup: Bool = false
    
    var body: some View {
        VStack(alignment: .center, content: {
            Form {
                KeyboardShortcuts.Recorder("Play/pause:", name: .playPause)
                KeyboardShortcuts.Recorder("Next track:", name: .nextTrack)
                KeyboardShortcuts.Recorder("Next track:", name: .previousTrack)
                KeyboardShortcuts.Recorder("Toggle mini player:", name: .showMiniPlayer)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                Spacer()
                
                Button("Done", action: self.finishShortcutsSetup)
            }
        })
    }
    
    private func finishShortcutsSetup() {
        self.viewedShortcutsSetup = true
        NSApplication.shared.sendAction(#selector(AppDelegate.finishShortcutsSetup), to: nil, from: nil)
    }
}

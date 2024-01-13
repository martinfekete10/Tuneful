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
        VStack {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding(.bottom, 5)
            
            VStack(alignment: .center, content: {
                Text("Global Keyboard Shortcuts")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("You can always change these later")
                    .font(.caption)
                    .foregroundColor(.secondary)
            })
            .padding(.bottom, 10)
            
            VStack(alignment: .leading, content: {
                
                Form {
                    KeyboardShortcuts.Recorder("Play/pause:", name: .playPause)
                    KeyboardShortcuts.Recorder("Next track:", name: .nextTrack)
                    KeyboardShortcuts.Recorder("Previous track:", name: .previousTrack)
                    KeyboardShortcuts.Recorder("Toggle mini player:", name: .showMiniPlayer)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                HStack {
                    Spacer()
                    
                    Button("Done", action: self.finishShortcutsSetup)
                }
            })
            .padding(.horizontal, 50)
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
    }
    
    private func finishShortcutsSetup() {
        self.viewedShortcutsSetup = true
        NSApplication.shared.sendAction(#selector(AppDelegate.finishShortcutsSetup), to: nil, from: nil)
    }
}

struct ShortcutsSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutsSetupView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

//
//  NotchSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 01/12/2024.
//

import SwiftUI
import Settings
import Defaults

struct NotchSettingsView: View {
    @Default(.showSongNotification) var showSongNotification
    @Default(.notificationDuration) var notificationDuration
    @Default(.notchEnabled) var notchEnabled
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection("") {
                    LuminareToggle("Enable notch integration", isOn: $notchEnabled)
                        .onChange(of: notchEnabled) { enabled in
                            print(enabled)
                            if enabled {
                                NSApplication.shared.sendAction(#selector(AppDelegate.showNotch), to: nil, from: nil)
                            } else {
                                NSApplication.shared.sendAction(#selector(AppDelegate.hideNotch), to: nil, from: nil)
                            }
                        }
                    
                    LuminareToggle("Show notification on song change", isOn: $showSongNotification)
                        .disabled(!notchEnabled)
                        .opacity(notchEnabled ? 1 : 0.7)
                    
                    LuminareSliderPicker(
                        "Notification duration",
                        Array(stride(from: 0.5, through: 5.0, by: 0.5)),
                        selection: $notificationDuration
                    ) { value in
                        LocalizedStringKey("\(value, specifier: "%.1f") s")
                    }
                    .disabled(!notchEnabled)
                    .opacity(notchEnabled ? 1 : 0.7)
                }
                .padding(.bottom, 10)
                
                Text("For Macs without notch, this will be displayed as floating window on top of the screen. You can hover over the middle of the screen top to show it.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(7)
            }
        }
    }
}

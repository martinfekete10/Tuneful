//
//  NotchSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 01/12/2024.
//

import SwiftUI
import Settings
import Luminare

struct NotchSettingsView: View {
    @AppStorage("notchEnabled") private var notchEnabled = true
    @AppStorage("showSongNotification") private var showSongNotification = true
    @AppStorage("notificationDuration") private var notificationDuration = 2.0
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareToggle("Enable notch player", isOn: $notchEnabled)
                
                LuminareSection("") {
                    LuminareToggle("Show notification on song change", isOn: $showSongNotification)
                    
                    LuminareSliderPicker(
                        "Notification duration",
                        Array(stride(from: 0.5, through: 5.0, by: 0.5)),
                        selection: $notificationDuration
                    ) { value in
                        LocalizedStringKey("\(value, specifier: "%.1f") s")
                    }
                    .disabled(!self.showSongNotification)
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

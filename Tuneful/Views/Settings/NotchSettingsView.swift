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
    @AppStorage("showSongNotification") private var showSongNotification = true
    @AppStorage("notificationDuration") private var notificationDuration = 2.0
    @AppStorage("notchPlayerEnabled") private var notchPlayerEnabled = true
    @AppStorage("notchPlayerOnClick") private var notchPlayerOnClick = false
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection("Notifications") {
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
                
                LuminareSection("Notch player") {
                    LuminareToggle("Enable notch player", isOn: $notchPlayerEnabled)
                    LuminareToggle("Only show notch player on notch click", isOn: $notchPlayerOnClick)
                }
            }
        }
    }
}

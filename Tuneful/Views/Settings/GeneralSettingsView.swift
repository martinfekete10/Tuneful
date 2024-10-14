//
//  GeneralSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/01/2024.
//

import SwiftUI
import Settings
import LaunchAtLogin

struct GeneralSettingsView: View {
    @AppStorage("connectedApp") private var connectedAppAppStorage = ConnectedApps.spotify
    @AppStorage("showSongNotification") private var showSongNotificationAppStorage = true
    @AppStorage("notificationDuration") private var notificationDurationAppStorage = 2.0
    
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showingAlert = false
    @State private var connectedApp: ConnectedApps
    @State private var showSongNotification: Bool
    @State private var notificationDuration: Double
    
    init() {
        @AppStorage("connectedApp") var connectedAppAppStorage = ConnectedApps.spotify
        @AppStorage("showSongNotification") var showSongNotificationAppStorage = true
        @AppStorage("notificationDuration") var notificationDurationAppStorage = 2.0
        
        self.connectedApp = connectedAppAppStorage
        self.showSongNotification = showSongNotificationAppStorage
        self.notificationDuration = notificationDurationAppStorage
    }
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LaunchAtLogin
                    .Toggle()
                    .toggleStyle(.switch)
            
            
                HStack {
                    Picker("Connect Tuneful to", selection: $connectedApp) {
                        ForEach(ConnectedApps.allCases, id: \.self) { value in
                            Text(value.localizedName).tag(value)
                        }
                    }
                    .onChange(of: connectedApp) { _ in
                        self.connectedAppAppStorage = connectedApp
                    }
                    .pickerStyle(.segmented)
                    
                    Button {
                        let consent = Helper.promptUserForConsent(for: connectedApp == .spotify ? Constants.Spotify.bundleID : Constants.AppleMusic.bundleID)
                        switch consent {
                        case .closed:
                            alertTitle = Text("\(Text(connectedApp.localizedName)) is not open")
                            alertMessage = Text("Please open \(Text(connectedApp.localizedName)) to enable permissions")
                        case .granted:
                            alertTitle = Text("Permission granted for \(Text(connectedApp.localizedName))")
                            alertMessage = Text("Start playing a song!")
                        case .notPrompted:
                            return
                        case .denied:
                            alertTitle = Text("Permission denied")
                            alertMessage = Text("Please go to System Settings > Privacy & Security > Automation, and check \(Text(connectedApp.localizedName)) under Tuneful")
                        }
                        showingAlert = true
                    } label: {
                        Image(systemName: "person.fill.questionmark")
                    }
                    .buttonStyle(.borderless)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: alertTitle, message: alertMessage, dismissButton: .default(Text("Got it!")))
                    }
                }
                
                Settings.Section(label: {
                    Text("Show song details on new song")
                }) {
                    Toggle(isOn: $showSongNotification) {
                        Text("")
                    }
                    .onChange(of: showSongNotification) { _ in
                        self.showSongNotificationAppStorage = showSongNotification
                    }
                    .toggleStyle(.switch)
                }
                
                Settings.Section(label: {
                    Text("Show notification for (s)")
                        .foregroundStyle(self.showSongNotification ? .primary : .tertiary)
                }) {
                    VStack(alignment: .center) {
                        Slider(value: $notificationDuration, in: 0.5...3.0, step: 0.5) {
                            Text("")
                        } minimumValueLabel: {
                            Text("0.5")
                        } maximumValueLabel: {
                            Text("3")
                        }
                        .onChange(of: notificationDuration) { _ in
                            self.notificationDurationAppStorage = notificationDuration
                        }
                        .frame(width: 200)
                        .disabled(!self.showSongNotification)
                        
                        Text("Notification will be shown for \(String(format: "%.1f", self.notificationDuration)) second(s)")     .foregroundStyle(self.showSongNotification ? .primary : .tertiary)
                            .font(.callout)
                    }
                }
            }
        }
    }
}

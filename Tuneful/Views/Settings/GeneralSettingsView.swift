//
//  GeneralSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/01/2024.
//

import SwiftUI
import Settings
import LaunchAtLogin
import Luminare

struct GeneralSettingsView: View {
    @AppStorage("connectedApp") private var connectedAppAppStorage = ConnectedApps.appleMusic
    @AppStorage("showSongNotification") private var showSongNotificationAppStorage = true
    @AppStorage("notificationDuration") private var notificationDurationAppStorage = 2.0
    
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showingAlert = false
    @State private var connectedApp: ConnectedApps
    @State private var showSongNotification: Bool
    @State private var notificationDuration: Double
    
    init() {
        @AppStorage("connectedApp") var connectedAppAppStorage = ConnectedApps.appleMusic
        @AppStorage("showSongNotification") var showSongNotificationAppStorage = true
        @AppStorage("notificationDuration") var notificationDurationAppStorage = 2.0
        
        self.connectedApp = connectedAppAppStorage
        self.showSongNotification = showSongNotificationAppStorage
        self.notificationDuration = notificationDurationAppStorage
    }
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection("General") {
                    LuminareToggle(
                        "Launch at login",
                        isOn: Binding(
                            get: { LaunchAtLogin.isEnabled },
                            set: { value in LaunchAtLogin.isEnabled = value }
                        )
                    )
                    
                    VStack {
                        HStack {
                            Text("Connect Tuneful to")
                            
                            Spacer()
                            
                            Picker("", selection: $connectedApp) {
                                ForEach(ConnectedApps.allCases.filter { $0.isInstalled }, id: \.self) { value in
                                    Text(value.localizedName)
                                        .tag(value)
                                }
                            }
                            .frame(width: 150)
                            .onChange(of: connectedApp) { _ in
                                self.connectedAppAppStorage = connectedApp
                            }
                            .pickerStyle(.menu)
                            
                            Button {
                                let consent = Helper.promptUserForConsent(for: connectedApp == .spotify ? Constants.Spotify.bundleID : Constants.AppleMusic.bundleID)
                                switch consent {
                                case .closed:
                                    alertTitle = Text("\(Text(connectedApp.localizedName)) is not opened")
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
                        .padding(8)
                        
                        if !ConnectedApps.spotify.isInstalled {
                            Text("Apple Music is the only avaiable music app as Spotify was not found. It should be located at the top level of Applications folder.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)
                        }
                    }
                }
                    
                LuminareSection("Notifications") {
                    LuminareToggle("Show notification on song change", isOn: $showSongNotificationAppStorage)
                    
                    LuminareSliderPicker(
                        "Notification duration",
                        Array(stride(from: 0.5, through: 5.0, by: 0.5)),
                        selection: $notificationDurationAppStorage
                    ) { value in
                        LocalizedStringKey("\(value, specifier: "%.1f") s")
                    }
                    .disabled(!self.showSongNotificationAppStorage)
                }
                .padding(.top, 10)
            }
        }
    }
}

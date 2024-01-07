//
//  SettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 06/01/2024.
//

import SwiftUI
import LaunchAtLogin
import Settings

struct GeneralSettingsView: View {
    
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.spotify
    
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showingAlert = false

    private var name: Text {
        Text(connectedApp.localizedName)
    }
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        LaunchAtLogin
                            .Toggle()
                        
                        HStack {
                            Picker("Connect Tuneful to", selection: $connectedApp) {
                                ForEach(ConnectedApps.allCases, id: \.self) { value in
                                    Text(value.localizedName).tag(value)
                                }
                            }
                            .pickerStyle(.segmented)
                            Button {
                                let consent = Helper.promptUserForConsent(for: connectedApp == .spotify ? Constants.Spotify.bundleID : Constants.AppleMusic.bundleID)
                                switch consent {
                                case .closed:
                                    alertTitle = Text("\(name) is not open")
                                    alertMessage = Text("Please open \(name) to enable permissions")
                                case .granted:
                                    alertTitle = Text("Permission granted for \(name)")
                                    alertMessage = Text("Start playing a song!")
                                case .notPrompted:
                                    return
                                case .denied:
                                    alertTitle = Text("Permission denied")
                                    alertMessage = Text("Please go to System Settings > Privacy & Security > Automation, and check \(name) under Tuneful")
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
                    }
                    .padding()
                }
            }
        }
    }
}

struct AppearanceSettingsView: View {
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
            }
        }
    }
}

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
    var title: String = "General"
    var systemImage: String = "switch.2"
    
    @AppStorage("connectedApp") private var connectedAppAppStorage = ConnectedApps.appleMusic
    
    @State private var connectedApp: ConnectedApps
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showingAlert = false
    
    init() {
        @AppStorage("connectedApp") var connectedAppAppStorage = ConnectedApps.appleMusic
        self.connectedApp = connectedAppAppStorage
    }
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection {
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
                            
                            HStack {
                                ForEach(ConnectedApps.allCases, id: \.rawValue) { app in
                                    LuminareSection() {
                                        Button(action: {
                                            connectedApp = app
                                            connectedAppAppStorage = app
                                        }) {
                                            app.getIcon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                        }
                                        .disabled(!app.selectable)
                                        .buttonStyle(PlainButtonStyle())
                                        .frame(width: 50, height: 50)
                                    }
                                    .if(connectedApp == app) { button in
                                        button.overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.secondary, lineWidth: 2)
                                        )
                                    }
                                }
                            }
                            .frame(width: 150)
                            
                            Button {
                                let consent = Helper.promptUserForConsent(for: connectedAppAppStorage == .spotify ? Constants.Spotify.bundleID : Constants.AppleMusic.bundleID)
                                switch consent {
                                case .closed:
                                    alertTitle = Text("\(Text(connectedAppAppStorage.localizedName)) is not opened")
                                    alertMessage = Text("Please open \(Text(connectedAppAppStorage.localizedName)) to enable permissions")
                                case .granted:
                                    alertTitle = Text("Permission granted for \(Text(connectedAppAppStorage.localizedName))")
                                    alertMessage = Text("Start playing a song!")
                                case .notPrompted:
                                    return
                                case .denied:
                                    alertTitle = Text("Permission denied")
                                    alertMessage = Text("Please go to System Settings > Privacy & Security > Automation, and check \(Text(connectedAppAppStorage.localizedName)) under Tuneful")
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
                        
                        if !ConnectedApps.spotify.selectable {
                            Text("Apple Music is the only avaiable music app as Spotify was not found. It should be located at the top level of Applications folder.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)
                        }
                    }
                }
            }
        }
    }
}

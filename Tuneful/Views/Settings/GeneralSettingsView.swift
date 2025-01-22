//
//  GeneralSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/01/2024.
//

import SwiftUI
import Settings
import LaunchAtLogin
import Defaults

struct GeneralSettingsView: View {
    @Default(.connectedApp) private var connectedApp
    
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showingAlert = false
    
    var body: some View {
        Settings.Container(contentWidth: Constants.settingsWindowWidth) {
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
                                        Button(action: { connectedApp = app }) {
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
                                let consent = PermissionHelper.promptUserForConsent(for: connectedApp == .spotify ? Constants.Spotify.bundleID : Constants.AppleMusic.bundleID)
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
                        
                        if !ConnectedApps.spotify.selectable {
                            Text("Apple Music is the only avaiable music app as Spotify was not found. It should be located at the top level of Applications folder.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)
                        }
                    }
                }
                
                Button(action: {
                    NSApplication.shared.sendAction(#selector(AppDelegate.quit), to: nil, from: nil)
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "power")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.secondary)
                            .frame(width: 15, height: 16)
                        
                        Text("Quit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(LuminareCompactButtonStyle())
            }
        }
    }
}

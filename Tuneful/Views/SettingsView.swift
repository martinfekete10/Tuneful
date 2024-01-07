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
    
    @AppStorage("showSongInfoAppStorage") var showSongInfoAppStorage: Bool = true
    @AppStorage("trackInfoLength") var trackInfoLength: Double = 20.0
    @AppStorage("statusBarIcon") var statusBarIcon: StatusBarIcon = .appIcon
    @AppStorage("trackInfoDetails") var trackInfoDetails: StatusBarTrackDetails = .artistAndSong
    
    // A bit of a hack, binded AppStorage variable doesn't refresh UI, first we read the app storage this way
    // and @AppStorage variable showSongInfoAppStorage is updated whenever the state changes using .onChange()
    @State var showSongInfo: Bool = UserDefaults.standard.bool(forKey: "showSongInfoAppStorage")
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            // Show song info - checkbox
            //
            // Max length of song info (20 chars default)
            // Dropdown - artist/song/song and artist
            // Dropdown - Show album art/app icon/ nothing
            
            Settings.Section(title: "Show song info") {
                Toggle(isOn: $showSongInfo) {
                    Text("")
                }
                .onChange(of: showSongInfo) { newValue in
                    self.showSongInfoAppStorage = showSongInfo
                }
                .toggleStyle(.switch)
            }
            
            Settings.Section(label: {
                Text("Track info max length")
                    .foregroundStyle(!showSongInfo ? .tertiary : .primary)
            }) {
                Slider(value: $trackInfoLength, in: 1...30, step: 5)
                    .disabled(!showSongInfo)
            }
            
            Settings.Section(label: {
                Text("Track info")
                    .foregroundStyle(!showSongInfo ? .tertiary : .primary)
            }) {
                Picker("", selection: $trackInfoDetails) {
                    ForEach(StatusBarTrackDetails.allCases, id: \.self) { value in
                        Text(value.localizedName).tag(value)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 200)
                .disabled(!showSongInfo)
            }
        }
    }
}

struct AboutSettingsView: View {
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                VStack(alignment: .center) {
                    Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("Tuneful").font(.headline)
                        Text("Version \(Constants.AppInfo.appVersion ?? "?")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

//
//  SettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 06/01/2024.
//

import SwiftUI
import Settings

struct MenuBarAppearanceSettingsView: View {
    
    @AppStorage("showSongInfo") var showSongInfoAppStorage: Bool = true
    @AppStorage("menuBarItemWidth") var menuBarItemWidthAppStorage: Double = 150
    @AppStorage("statusBarIcon") var statusBarIconAppStorage: StatusBarIcon = .albumArt
    @AppStorage("trackInfoDetails") var trackInfoDetailsAppStorage: StatusBarTrackDetails = .artistAndSong
    @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .transparent
    @AppStorage("hideSongInfoWhenNotPlaying") var hideSongInfoWhenNotPlayingAppStorage: Bool = false
    
    // A bit of a hack, binded AppStorage variable doesn't refresh UI, first we read the app storage this way
    // and @AppStorage variable  is updated whenever the state changes using .onChange()
    @State var showSongInfo: Bool
    @State var menuBarItemWidth: Double
    @State var statusBarIcon: StatusBarIcon
    @State var trackInfoDetails: StatusBarTrackDetails
    @State var popoverBackground: BackgroundType
    @State var hideSongInfoWhenNotPlaying: Bool
    
    init() {
        @AppStorage("showSongInfo") var showSongInfoAppStorage: Bool = true
        @AppStorage("menuBarItemWidth") var menuBarItemWidthAppStorage: Double = 150
        @AppStorage("statusBarIcon") var statusBarIconAppStorage: StatusBarIcon = .albumArt
        @AppStorage("trackInfoDetails") var trackInfoDetailsAppStorage: StatusBarTrackDetails = .artistAndSong
        @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .transparent
        @AppStorage("hideSongInfoWhenNotPlaying") var hideSongInfoWhenNotPlayingAppStorage: Bool = false
        
        self.showSongInfo = showSongInfoAppStorage
        self.menuBarItemWidth = menuBarItemWidthAppStorage
        self.statusBarIcon = statusBarIconAppStorage
        self.trackInfoDetails = trackInfoDetailsAppStorage
        self.popoverBackground = popoverBackgroundAppStorage
        self.hideSongInfoWhenNotPlaying = hideSongInfoWhenNotPlayingAppStorage
    }

    var body: some View {
        VStack {
            Settings.Container(contentWidth: 400) {
                
                Settings.Section(label: {
                    Text("Menu bar icon")
                }) {
                    Picker("", selection: $statusBarIcon) {
                        ForEach(StatusBarIcon.allCases, id: \.self) { value in
                            Text(value.localizedName).tag(value)
                        }
                    }
                    .onChange(of: statusBarIcon) { _ in
                        self.statusBarIconAppStorage = statusBarIcon
                        self.sendTrackChangedNotification()
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                Settings.Section(label: {
                    Text("Popover background")
                }) {
                    Picker("", selection: $popoverBackground) {
                        ForEach(BackgroundType.allCases, id: \.self) { value in
                            Text(value.localizedName).tag(value)
                        }
                    }
                    .onChange(of: popoverBackground) { newValue in
                        self.popoverBackgroundAppStorage = popoverBackground
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                Settings.Section(title: "Show song info in menu bar") {
                    Toggle(isOn: $showSongInfo) {
                        Text("")
                    }
                    .onChange(of: showSongInfo) { show in
                        self.showSongInfoAppStorage = showSongInfo
                        self.sendTrackChangedNotification()
                    }
                    .toggleStyle(.switch)
                }
                
                Settings.Section(label: {
                    Text("Hide song info when not playing")
                        .foregroundStyle(!showSongInfo ? .tertiary : .primary)
                }) {
                    Toggle(isOn: $hideSongInfoWhenNotPlaying) {
                        Text("")
                    }
                    .onChange(of: hideSongInfoWhenNotPlaying) { show in
                        self.hideSongInfoWhenNotPlayingAppStorage = hideSongInfoWhenNotPlaying
                        self.sendTrackChangedNotification()
                    }
                    .toggleStyle(.switch)
                    .disabled(!showSongInfo)
                }
                
                Settings.Section(label: {
                    Text("Song info details")
                        .foregroundStyle(!showSongInfo ? .tertiary : .primary)
                }) {
                    Picker("", selection: $trackInfoDetails) {
                        ForEach(StatusBarTrackDetails.allCases, id: \.self) { value in
                            Text(value.localizedName).tag(value)
                        }
                    }
                    .onChange(of: trackInfoDetails) { newValue in
                        self.trackInfoDetailsAppStorage = trackInfoDetails
                        self.sendTrackChangedNotification()
                    }
                    .pickerStyle(.menu)
                    .frame(width: 200)
                    .disabled(!showSongInfo)
                }
                
                Settings.Section(label: {
                    Text("Song info max length")
                        .foregroundStyle(!showSongInfo ? .tertiary : .primary)
                }) {
                    VStack(alignment: .center) {
                        Slider(value: $menuBarItemWidth, in: 100...300, step: 25) {
                            Text("")
                        } minimumValueLabel: {
                            Text("100")
                        } maximumValueLabel: {
                            Text("300")
                        }
                        .onChange(of: menuBarItemWidth) { newValue in
                            self.menuBarItemWidthAppStorage = menuBarItemWidth
                            self.sendTrackChangedNotification()
                            NSHapticFeedbackManager.defaultPerformer.perform(NSHapticFeedbackManager.FeedbackPattern.levelChange, performanceTime: .now)
                        }
                        .frame(width: 200)
                        .disabled(!showSongInfo)
                        
                        Text("Width: \(Int(self.menuBarItemWidth)) pixels")
                            .foregroundStyle(!showSongInfo ? .tertiary : .secondary)
                            .font(.callout)
                    }
                }
            }
        }
    }
    
    private func sendTrackChangedNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateMenuBarItem"), object: nil, userInfo: [:])
    }
}

struct MenuBarAppearanceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarAppearanceSettingsView()
            .previewLayout(.device)
            .padding()
    }
}

//
//  MenuBarSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 06/01/2024.
//

import SwiftUI
import Settings
import Luminare

struct MenuBarSettingsView: View, SettingsProtocol {
    var title: String = "Menu bar"
    var systemImage: String = "menubar.rectangle"
    
    @AppStorage("menuBarItemWidth") var menuBarItemWidthAppStorage: Double = 150
    @AppStorage("statusBarIcon") var statusBarIconAppStorage: StatusBarIcon = .albumArt
    @AppStorage("trackInfoDetails") var trackInfoDetailsAppStorage: StatusBarTrackDetails = .artistAndSong
    @AppStorage("showStatusBarTrackInfo") var showStatusBarTrackInfoAppStorage: ShowStatusBarTrackInfo = .always
    @AppStorage("showMenuBarPlaybackControls") var showMenuBarPlaybackControlsAppStorage: Bool = false
    @AppStorage("hideMenuBarItemWhenNotPlaying") var hideMenuBarItemWhenNotPlayingAppStorage: Bool = false
    @AppStorage("scrollingTrackInfo") var scrollingTrackInfoAppStorage: Bool = false
    @AppStorage("showEqWhenPlayingMusic") var showEqWhenPlayingMusicAppStorage: Bool = true
    
    // A bit of a hack, binded AppStorage variable doesn't refresh UI, first we read the app storage this way
    // and @AppStorage variable  is updated whenever the state changes using .onChange()
    @State var menuBarItemWidth: Double
    @State var statusBarIcon: StatusBarIcon
    @State var trackInfoDetails: StatusBarTrackDetails
    @State var showStatusBarTrackInfo: ShowStatusBarTrackInfo
    @State var showMenuBarPlaybackControls: Bool
    @State var hideMenuBarItemWhenNotPlaying: Bool
    @State var scrollingTrackInfo: Bool
    @State var showEqWhenPlayingMusic: Bool
    
    init() {
        @AppStorage("menuBarItemWidth") var menuBarItemWidthAppStorage: Double = 150
        @AppStorage("statusBarIcon") var statusBarIconAppStorage: StatusBarIcon = .albumArt
        @AppStorage("trackInfoDetails") var trackInfoDetailsAppStorage: StatusBarTrackDetails = .artistAndSong
        @AppStorage("showStatusBarTrackInfo") var showStatusBarTrackInfoAppStorage: ShowStatusBarTrackInfo = .always
        @AppStorage("showMenuBarPlaybackControls") var showMenuBarPlaybackControlsAppStorage: Bool = false
        @AppStorage("hideMenuBarItemWhenNotPlaying") var hideMenuBarItemWhenNotPlayingAppStorage: Bool = false
        @AppStorage("scrollingTrackInfo") var scrollingTrackInfoAppStorage: Bool = false
        @AppStorage("showEqWhenPlayingMusic") var showEqWhenPlayingMusicAppStorage: Bool = true
        
        self.menuBarItemWidth = menuBarItemWidthAppStorage
        self.statusBarIcon = statusBarIconAppStorage
        self.trackInfoDetails = trackInfoDetailsAppStorage
        self.showStatusBarTrackInfo = showStatusBarTrackInfoAppStorage
        self.showMenuBarPlaybackControls = showMenuBarPlaybackControlsAppStorage
        self.hideMenuBarItemWhenNotPlaying = hideMenuBarItemWhenNotPlayingAppStorage
        self.scrollingTrackInfo = scrollingTrackInfoAppStorage
        self.showEqWhenPlayingMusic = showEqWhenPlayingMusicAppStorage
    }

    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection("General") {
                    HStack {
                        Text("Menu bar icon")
                        
                        Spacer()
                        
                        Picker("", selection: $statusBarIcon) {
                            ForEach(StatusBarIcon.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .frame(width: 150)
                        .onChange(of: statusBarIcon) { _ in
                            self.statusBarIconAppStorage = statusBarIcon
                            
                            if statusBarIcon == .hidden && showStatusBarTrackInfo == .never {
                                showStatusBarTrackInfo = .whenPlaying
                            }
                            
                            self.sendTrackChangedNotification()
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(8)
                    
                    LuminareToggle("Show equalizer when playing music", isOn: $showEqWhenPlayingMusicAppStorage)
                        .onChange(of: showEqWhenPlayingMusicAppStorage) { _ in
                            self.sendTrackChangedNotification()
                        }
                    
                    HStack {
                        Text("Hide menu bar item when nothing is playing")
                        
                        Spacer()
                        
                        Toggle(isOn: $hideMenuBarItemWhenNotPlaying) {
                            Text("")
                        }
                        .onChange(of: hideMenuBarItemWhenNotPlaying) { _ in
                            self.hideMenuBarItemWhenNotPlayingAppStorage = hideMenuBarItemWhenNotPlaying
                            self.sendTrackChangedNotification()
                        }
                        .toggleStyle(.switch)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Show playback controls")
                        
                        Spacer()
                        
                        Toggle(isOn: $showMenuBarPlaybackControls) {
                            Text("")
                        }
                        .onChange(of: showMenuBarPlaybackControls) { _ in
                            self.showMenuBarPlaybackControlsAppStorage = showMenuBarPlaybackControls
                            NSApplication.shared.sendAction(#selector(AppDelegate.menuBarPlaybackControls), to: nil, from: nil)
                        }
                        .toggleStyle(.switch)
                    }
                    .padding(8)
                }
                
                LuminareSection("Song information in menu bar") {
                    HStack {
                        Text("Song info in menu bar")
                        
                        Spacer()
                        
                        Picker("", selection: $showStatusBarTrackInfo) {
                            ForEach(ShowStatusBarTrackInfo.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .onChange(of: showStatusBarTrackInfo) { _ in
                            self.showStatusBarTrackInfoAppStorage = showStatusBarTrackInfo
                            
                            if statusBarIcon == .hidden && showStatusBarTrackInfo == .never {
                                statusBarIcon = .appIcon
                            }
                            
                            self.sendTrackChangedNotification()
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Song info details")
                            .foregroundStyle(self.showStatusBarTrackInfo == .never ? .tertiary : .primary)
                        
                        Spacer()
                        
                        Picker("", selection: $trackInfoDetails) {
                            ForEach(StatusBarTrackDetails.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .onChange(of: trackInfoDetails) { _ in
                            self.trackInfoDetailsAppStorage = trackInfoDetails
                            self.sendTrackChangedNotification()
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                        .disabled(self.showStatusBarTrackInfo == .never)
                    }
                    .padding(8)
                    
                    LuminareSliderPicker(
                        "Song info width",
                        Array(stride(from: 75, through: 300, by: 25)),
                        selection: $menuBarItemWidthAppStorage
                    ) { value in
                        LocalizedStringKey("\(value, specifier: "%.0f") pixels")
                    }
                    .onChange(of: menuBarItemWidthAppStorage) { _ in
                        self.sendTrackChangedNotification()
                        NSHapticFeedbackManager.defaultPerformer.perform(NSHapticFeedbackManager.FeedbackPattern.levelChange, performanceTime: .now)
                    }
                    .disabled(self.showStatusBarTrackInfo == .never)
                    
                    HStack {
                        Text("Scrolling song info")
                            .foregroundStyle(self.showStatusBarTrackInfo == .never ? .tertiary : .primary)
                        
                        Spacer()
                        
                        Toggle(isOn: $scrollingTrackInfo) {
                            Text("")
                        }
                        .onChange(of: scrollingTrackInfo) { _ in
                            self.scrollingTrackInfoAppStorage = scrollingTrackInfo
                            self.sendTrackChangedNotification()
                        }
                        .toggleStyle(.switch)
                        .disabled(self.showStatusBarTrackInfo == .never)
                    }
                    .padding(8)
                }
                .padding(.top, 10)
            }
        }
    }
    
    private func sendTrackChangedNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateMenuBarItem"), object: nil, userInfo: [:])
    }
}

#Preview {
    MenuBarSettingsView()
}

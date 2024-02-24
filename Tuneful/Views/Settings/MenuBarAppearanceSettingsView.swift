//
//  SettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 06/01/2024.
//

import SwiftUI
import Settings

struct MenuBarAppearanceSettingsView: View {
    
    @AppStorage("menuBarItemWidth") var menuBarItemWidthAppStorage: Double = 150
    @AppStorage("statusBarIcon") var statusBarIconAppStorage: StatusBarIcon = .albumArt
    @AppStorage("trackInfoDetails") var trackInfoDetailsAppStorage: StatusBarTrackDetails = .artistAndSong
    @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .transparent
    @AppStorage("showStatusBarTrackInfo") var showStatusBarTrackInfoAppStorage: ShowStatusBarTrackInfo = .always
    @AppStorage("showMenuBarPlaybackControls") var showMenuBarPlaybackControlsAppStorage: Bool = true
    
    // A bit of a hack, binded AppStorage variable doesn't refresh UI, first we read the app storage this way
    // and @AppStorage variable  is updated whenever the state changes using .onChange()
    @State var menuBarItemWidth: Double
    @State var statusBarIcon: StatusBarIcon
    @State var trackInfoDetails: StatusBarTrackDetails
    @State var popoverBackground: BackgroundType
    @State var showStatusBarTrackInfo: ShowStatusBarTrackInfo
    @State var showMenuBarPlaybackControls: Bool
    
    init() {
        @AppStorage("menuBarItemWidth") var menuBarItemWidthAppStorage: Double = 150
        @AppStorage("statusBarIcon") var statusBarIconAppStorage: StatusBarIcon = .albumArt
        @AppStorage("trackInfoDetails") var trackInfoDetailsAppStorage: StatusBarTrackDetails = .artistAndSong
        @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .transparent
        @AppStorage("showStatusBarTrackInfo") var showStatusBarTrackInfoAppStorage: ShowStatusBarTrackInfo = .always
        @AppStorage("showMenuBarPlaybackControls") var showMenuBarPlaybackControlsAppStorage: Bool = true
        
        self.menuBarItemWidth = menuBarItemWidthAppStorage
        self.statusBarIcon = statusBarIconAppStorage
        self.trackInfoDetails = trackInfoDetailsAppStorage
        self.popoverBackground = popoverBackgroundAppStorage
        self.showStatusBarTrackInfo = showStatusBarTrackInfoAppStorage
        self.showMenuBarPlaybackControls = showMenuBarPlaybackControlsAppStorage
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
                
                Settings.Section(label: {
                    Text("Show song info in menu bar")
                }) {
                    Picker("", selection: $showStatusBarTrackInfo) {
                        ForEach(ShowStatusBarTrackInfo.allCases, id: \.self) { value in
                            Text(value.localizedName).tag(value)
                        }
                    }
                    .onChange(of: showStatusBarTrackInfo) { newValue in
                        self.showStatusBarTrackInfoAppStorage = showStatusBarTrackInfo
                        self.sendTrackChangedNotification()
                    }
                    .pickerStyle(.menu)
                    .frame(width: 200)
                }
                
                Settings.Section(label: {
                    Text("Song info details")
                        .foregroundStyle(self.showStatusBarTrackInfo == .never ? .tertiary : .primary)
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
                    .disabled(self.showStatusBarTrackInfo == .never)
                }
                
                Settings.Section(label: {
                    Text("Song info width")
                        .foregroundStyle(self.showStatusBarTrackInfo == .never ? .tertiary : .primary)
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
                        .disabled(self.showStatusBarTrackInfo == .never)
                        
                        Text("Width: \(Int(self.menuBarItemWidth)) pixels")
                            .foregroundStyle(self.showStatusBarTrackInfo == .never ? .tertiary : .primary)
                            .font(.callout)
                    }
                }
                
                Settings.Section(label: {
                    Text("Show player controls")
                }) {
                    Toggle(isOn: $showMenuBarPlaybackControls) {
                        Text("")
                    }
                    .onChange(of: showMenuBarPlaybackControls) { _ in
                        self.showMenuBarPlaybackControlsAppStorage = showMenuBarPlaybackControls
                        NSApplication.shared.sendAction(#selector(AppDelegate.menuBarPlaybackControls), to: nil, from: nil)
                    }
                    .toggleStyle(.switch)
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

//
//  AppearanceSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 01/12/2024.
//

import SwiftUI
import Settings
import Luminare

struct AppearanceSettingsView: View {
    @AppStorage("popoverType") var popoverTypeAppStorage: PopoverType = .full
    @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .albumArt
    @AppStorage("popoverIsEnabled") var popoverIsEnabledAppStorage: Bool = true
    
    // A bit of a hack, binded AppStorage variable doesn't refresh UI, first we read the app storage this way
    // and @AppStorage variable  is updated whenever the state changes using .onChange()
    @State var popoverType: PopoverType
    @State var popoverBackground: BackgroundType
    @State var popoverIsEnabled: Bool
    
    @AppStorage("miniPlayerBackground") var miniPlayerBackgroundAppStorage: BackgroundType = .albumArt
    @AppStorage("showPlayerWindow") var showPlayerWindowAppStorage: Bool = true
    @AppStorage("miniPlayerType") var miniPlayerTypeAppStorage: MiniPlayerType = .minimal
    @AppStorage("miniPlayerWindowOnTop") var miniPlayerWindowOnTopAppStorage: Bool = true
    
    // A bit of a hack, binded AppStorage variable doesn't refresh UI, first we read the app storage this way
    // and @AppStorage variable  is updated whenever the state changes using .onChange()
    @State var miniPlayerBackground: BackgroundType
    @State var showPlayerWindow: Bool
    @State var miniPlayerType: MiniPlayerType
    @State var miniPlayerWindowOnTop: Bool
    
    init() {
        @AppStorage("popoverType") var popoverTypeAppStorage: PopoverType = .full
        @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .albumArt
        @AppStorage("popoverIsEnabled") var popoverIsEnabledAppStorage: Bool = true
        
        self.popoverType = popoverTypeAppStorage
        self.popoverBackground = popoverBackgroundAppStorage
        self.popoverIsEnabled = popoverIsEnabledAppStorage
        
        @AppStorage("miniPlayerBackground") var miniPlayerBackgroundAppStorage: BackgroundType = .albumArt
        @AppStorage("showPlayerWindow") var showPlayerWindowAppStorage: Bool = true
        @AppStorage("miniPlayerType") var miniPlayerTypeAppStorage: MiniPlayerType = .minimal
        @AppStorage("miniPlayerWindowOnTop") var miniPlayerWindowOnTopAppStorage: Bool = true
        
        self.miniPlayerBackground = miniPlayerBackgroundAppStorage
        self.showPlayerWindow = showPlayerWindowAppStorage
        self.miniPlayerType = miniPlayerTypeAppStorage
        self.miniPlayerWindowOnTop = miniPlayerWindowOnTopAppStorage
    }
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection("Popover") {
                    LuminareToggle(
                        "Enable popover",
                        isOn: $popoverIsEnabled
                    )
                    .onChange(of: popoverIsEnabled) { _ in
                        self.popoverIsEnabledAppStorage = popoverIsEnabled
                    }
                    
                    HStack {
                        Text("Popover style")
                            .foregroundStyle(self.popoverIsEnabledAppStorage ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker("", selection: $popoverType) {
                            ForEach(PopoverType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                        .onChange(of: popoverType) { _ in
                            self.popoverTypeAppStorage = popoverType
                            NSApplication.shared.sendAction(#selector(AppDelegate.setupPopover), to: nil, from: nil)
                        }
                        .disabled(!popoverIsEnabledAppStorage)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Popover background")
                            .foregroundStyle(self.popoverIsEnabledAppStorage ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker("", selection: $popoverBackground) {
                            ForEach(BackgroundType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .onChange(of: popoverBackground) { _ in
                            self.popoverBackgroundAppStorage = popoverBackground
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                        .disabled(!popoverIsEnabledAppStorage)
                    }
                    .padding(8)
                }
                
                LuminareSection("Mini player") {
                    LuminareToggle(
                        "Show mini player",
                        isOn: $showPlayerWindow
                    )
                    .onChange(of: showPlayerWindow) { _ in
                        self.showPlayerWindowAppStorage = showPlayerWindow
                        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayer), to: nil, from: nil)
                    }
                    
                    LuminareToggle(
                        "Mini player window always on top of other apps",
                        isOn: $miniPlayerWindowOnTopAppStorage
                    )
                    .onChange(of: miniPlayerWindowOnTopAppStorage) { _ in
                        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayerWindowLevel), to: nil, from: nil)
                    }
                    
                    HStack {
                        Text("Background")
                            .foregroundStyle(self.showPlayerWindowAppStorage ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker("", selection: $miniPlayerBackground) {
                            ForEach(BackgroundType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                        .onChange(of: miniPlayerBackground) { newValue in
                            self.miniPlayerBackgroundAppStorage = miniPlayerBackground
                        }
                        .disabled(!showPlayerWindowAppStorage)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Window style")
                            .foregroundStyle(self.showPlayerWindowAppStorage ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker(selection: $miniPlayerType, label: Text("")) {
                            ForEach(MiniPlayerType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                        .onChange(of: miniPlayerType) { _ in
                            self.miniPlayerTypeAppStorage = miniPlayerType
                            NSApplication.shared.sendAction(#selector(AppDelegate.setupMiniPlayer), to: nil, from: nil)
                        }
                        .disabled(!showPlayerWindowAppStorage)
                    }
                    .padding(8)
                }
            }
        }
    }
}

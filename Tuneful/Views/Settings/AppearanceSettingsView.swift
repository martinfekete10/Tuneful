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
    @AppStorage("popoverIsEnabled") var popoverIsEnabledAppStorage: Bool = true
    @AppStorage("popoverType") var popoverTypeAppStorage: PopoverType = .full
    @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .transparent
    
    @AppStorage("showPlayerWindow") var showPlayerWindowAppStorage: Bool = true
    @AppStorage("miniPlayerWindowOnTop") var miniPlayerWindowOnTopAppStorage: Bool = true
    @AppStorage("miniPlayerType") var miniPlayerTypeAppStorage: MiniPlayerType = .minimal
    @AppStorage("miniPlayerBackground") var miniPlayerBackgroundAppStorage: BackgroundType = .transparent
    
    @State var showPlayerWindow: Bool
    @State var miniPlayerWindowOnTop: Bool
    @State var miniPlayerType: MiniPlayerType = .minimal
    @State var miniPlayerBackground: BackgroundType = .transparent
    
    @State var popoverIsEnabled: Bool
    @State var popoverType: PopoverType = .full
    @State var popoverBackground: BackgroundType = .transparent
    
    init() {
        @AppStorage("showPlayerWindow") var showPlayerWindowAppStorage: Bool = true
        @AppStorage("miniPlayerWindowOnTop") var miniPlayerWindowOnTopAppStorage: Bool = true
        @AppStorage("miniPlayerType") var miniPlayerTypeAppStorage: MiniPlayerType = .minimal
        @AppStorage("miniPlayerBackground") var miniPlayerBackgroundAppStorage: BackgroundType = .transparent
        self.showPlayerWindow = showPlayerWindowAppStorage
        self.miniPlayerWindowOnTop = miniPlayerWindowOnTopAppStorage
        self.miniPlayerType = miniPlayerTypeAppStorage
        self.miniPlayerBackground = miniPlayerBackgroundAppStorage
        
        @AppStorage("popoverIsEnabled") var popoverIsEnabledAppStorage: Bool = true
        @AppStorage("popoverType") var popoverTypeAppStorage: PopoverType = .full
        @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .transparent
        self.popoverIsEnabled = popoverIsEnabledAppStorage
        self.popoverType = popoverTypeAppStorage
        self.popoverBackground = popoverBackgroundAppStorage
    }
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection("Popover") {
                    LuminareToggle(
                        "Enable popover",
                        isOn: $popoverIsEnabled
                    )
                    
                    HStack {
                        Text("Popover style")
                            .foregroundStyle(self.popoverIsEnabled ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker("", selection: $popoverType) {
                            ForEach(PopoverType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                        .onChange(of: popoverType) { _ in
                            self.popoverTypeAppStorage = popoverType
                            NSApplication.shared.sendAction(#selector(AppDelegate.setupPopover), to: nil, from: nil)
                        }
                        .disabled(!popoverIsEnabled)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Popover background")
                            .foregroundStyle(self.popoverIsEnabled ? .primary : .tertiary)
                        
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
                        .frame(width: 200)
                        .disabled(!popoverIsEnabled)
                    }
                    .padding(8)
                }
                .padding(.bottom, 10)
                
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
                        isOn: $miniPlayerWindowOnTop
                    )
                    .onChange(of: miniPlayerWindowOnTop) { _ in
                        self.miniPlayerWindowOnTopAppStorage = miniPlayerWindowOnTop
                        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayerWindowLevel), to: nil, from: nil)
                    }
                    
                    HStack {
                        Text("Background")
                            .foregroundStyle(self.showPlayerWindow ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker("", selection: $miniPlayerBackground) {
                            ForEach(BackgroundType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                        .onChange(of: miniPlayerBackground) { _ in
                            self.miniPlayerBackgroundAppStorage = miniPlayerBackground
                            NSApplication.shared.sendAction(#selector(AppDelegate.setupMiniPlayer), to: nil, from: nil)
                        }
                        .disabled(!showPlayerWindow)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Window style")
                            .foregroundStyle(self.showPlayerWindow ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker(selection: $miniPlayerType, label: Text("")) {
                            ForEach(MiniPlayerType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                        .onChange(of: miniPlayerType) { _ in
                            self.miniPlayerTypeAppStorage = miniPlayerType
                            NSApplication.shared.sendAction(#selector(AppDelegate.setupMiniPlayer), to: nil, from: nil)
                        }
                        .disabled(!showPlayerWindow)
                    }
                    .padding(8)
                }
            }
        }
    }
}

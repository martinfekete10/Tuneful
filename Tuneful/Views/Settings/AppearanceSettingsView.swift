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
    @AppStorage("popoverType") var popoverType: PopoverType = .full
    @AppStorage("popoverBackground") var popoverBackground: BackgroundType = .transparent
    
    @AppStorage("showPlayerWindow") var showPlayerWindowAppStorage: Bool = true
    @AppStorage("miniPlayerWindowOnTop") var miniPlayerWindowOnTop: Bool = true
    @AppStorage("miniPlayerType") var miniPlayerType: MiniPlayerType = .minimal
    @AppStorage("miniPlayerBackground") var miniPlayerBackground: BackgroundType = .transparent
    
    @State var popoverIsEnabled: Bool
    @State var showPlayerWindow: Bool
    
    init() {
        @AppStorage("popoverIsEnabled") var popoverIsEnabledAppStorage: Bool = true
        @AppStorage("showPlayerWindow") var showPlayerWindowAppStorage: Bool = true
        
        self.popoverIsEnabled = popoverIsEnabledAppStorage
        self.showPlayerWindow = showPlayerWindowAppStorage
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
                        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayer), to: nil, from: nil)
                    }
                    
                    LuminareToggle(
                        "Mini player window always on top of other apps",
                        isOn: $miniPlayerWindowOnTop
                    )
                    .onChange(of: miniPlayerWindowOnTop) { _ in
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

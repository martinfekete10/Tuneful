//
//  AppearanceSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 01/12/2024.
//

import SwiftUI
import Settings
import Luminare
import Defaults

struct AppearanceSettingsView: View {
    @Default(.popoverIsEnabled) private var popoverIsEnabled
    @Default(.popoverType) private var popoverType
    @Default(.popoverBackground) private var popoverBackground
    
    @Default(.showPlayerWindow) private var showPlayerWindow
    @Default(.miniPlayerWindowOnTop) private var miniPlayerWindowOnTop
    @Default(.miniPlayerType) private var miniPlayerType
    @Default(.miniPlayerBackground) private var miniPlayerBackground
    @Default(.miniPlayerScaleFactor) private var miniPlayerScaleFactor
    
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
                            .foregroundStyle(popoverIsEnabled ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker("", selection: $popoverType) {
                            ForEach(PopoverType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .frame(width: 150)
                        .onChange(of: popoverType) { _ in
                            NSApplication.shared.sendAction(#selector(AppDelegate.setupPopover), to: nil, from: nil)
                        }
                        .disabled(!popoverIsEnabled)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Background")
                            .foregroundStyle(popoverIsEnabled ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker("", selection: $popoverBackground) {
                            ForEach(BackgroundType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .frame(width: 150)
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
                    
                    HStack {
                        Text("Mini player window always on top of other apps")
                            .foregroundStyle(showPlayerWindow ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $miniPlayerWindowOnTop)
                            .toggleStyle(.switch)
                            .disabled(!showPlayerWindow)
                            .controlSize(.small)
                            .onChange(of: miniPlayerWindowOnTop) { _ in
                                NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayerWindowLevel), to: nil, from: nil)
                            }
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Window style")
                            .foregroundStyle(showPlayerWindow ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker(selection: $miniPlayerType, label: Text("")) {
                            ForEach(MiniPlayerType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .frame(width: 150)
                        .disabled(!showPlayerWindow)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Background")
                            .foregroundStyle(showPlayerWindow ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker("", selection: $miniPlayerBackground) {
                            ForEach(BackgroundType.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .frame(width: 150)
                        .disabled(!showPlayerWindow)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Size")
                            .foregroundStyle(showPlayerWindow ? .primary : .tertiary)
                        
                        Spacer()
                        
                        Picker("", selection: $miniPlayerScaleFactor) {
                            ForEach(MiniPlayerScaleFactor.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .onChange(of: miniPlayerScaleFactor) { _ in
                            NSApplication.shared.sendAction(#selector(AppDelegate.setupMiniPlayer), to: nil, from: nil)
                        }
                        .frame(width: 150)
                        .disabled(!showPlayerWindow)
                    }
                    .padding(8)
                }
            }
        }
    }
}

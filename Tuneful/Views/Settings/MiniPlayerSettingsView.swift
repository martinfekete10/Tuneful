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

struct MiniPlayerSettingsView: View {
    @Default(.showPlayerWindow) private var showPlayerWindow
    @Default(.miniPlayerWindowOnTop) private var miniPlayerWindowOnTop
    @Default(.miniPlayerType) private var miniPlayerType
    @Default(.miniPlayerBackground) private var miniPlayerBackground
    @Default(.miniPlayerScaleFactor) private var miniPlayerScaleFactor
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection {
                    HStack {
                        Text("Show mini player")
                        
                        Spacer()
                        
                        Defaults.Toggle("", key: .showPlayerWindow)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    .padding(8)
                    
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
                        .frame(width: 150)
                        .disabled(!showPlayerWindow)
                    }
                    .padding(8)
                }
            }
        }
    }
}

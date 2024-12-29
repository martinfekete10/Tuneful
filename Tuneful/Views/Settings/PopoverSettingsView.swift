//
//  AppearanceSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 01/12/2024.
//

import SwiftUI
import Settings
import Defaults

struct PopoverSettingsView: View {
    @Default(.popoverIsEnabled) private var popoverIsEnabled
    @Default(.popoverType) private var popoverType
    @Default(.popoverBackground) private var popoverBackground
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection {
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
            }
        }
    }
}

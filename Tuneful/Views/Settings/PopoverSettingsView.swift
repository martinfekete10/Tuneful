//
//  PopoverSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/06/2024.
//

import SwiftUI
import Settings
import Luminare

struct PopoverSettingsView: View {
    
    @AppStorage("popoverType") var popoverTypeAppStorage: PopoverType = .full
    @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .albumArt
    @AppStorage("popoverIsEnabled") var popoverIsEnabledAppStorage: Bool = true
    
    // A bit of a hack, binded AppStorage variable doesn't refresh UI, first we read the app storage this way
    // and @AppStorage variable  is updated whenever the state changes using .onChange()
    @State var popoverType: PopoverType
    @State var popoverBackground: BackgroundType
    @State var popoverIsEnabled: Bool
    
    init() {
        @AppStorage("popoverType") var popoverTypeAppStorage: PopoverType = .full
        @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .albumArt
        @AppStorage("popoverIsEnabled") var popoverIsEnabledAppStorage: Bool = true

        self.popoverType = popoverTypeAppStorage
        self.popoverBackground = popoverBackgroundAppStorage
        self.popoverIsEnabled = popoverIsEnabledAppStorage
    }
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection {
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
            }
        }
    }
}

#Preview {
    PopoverSettingsView()
}

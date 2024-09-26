//
//  PopoverSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/06/2024.
//

import SwiftUI
import Settings

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
        Settings.Container(contentWidth: 350) {
            Settings.Section(label: {
                Text("Enable popover")
            }) {
                Toggle(isOn: $popoverIsEnabled) {
                    Text("")
                }
                .onChange(of: popoverIsEnabled) { _ in
                    self.popoverIsEnabledAppStorage = popoverIsEnabled
                }
                .toggleStyle(.switch)
            }
            
            Settings.Section(label: {
                Text("Popover style")
                    .foregroundStyle(self.popoverIsEnabled ? .primary : .tertiary)
            }) {
                Picker(selection: $popoverType, label: Text("")) {
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
            
            Settings.Section(label: {
                Text("Popover background")
                    .foregroundStyle(self.popoverIsEnabled ? .primary : .tertiary)
            }) {
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
            
        }
    }
}

#Preview {
    PopoverSettingsView()
}

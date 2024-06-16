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
    
    // A bit of a hack, binded AppStorage variable doesn't refresh UI, first we read the app storage this way
    // and @AppStorage variable  is updated whenever the state changes using .onChange()
    @State var popoverType: PopoverType
    @State var popoverBackground: BackgroundType
    
    init() {
        @AppStorage("popoverType") var popoverTypeAppStorage: PopoverType = .full
        @AppStorage("popoverBackground") var popoverBackgroundAppStorage: BackgroundType = .albumArt

        self.popoverType = popoverTypeAppStorage
        self.popoverBackground = popoverBackgroundAppStorage
    }
    
    var body: some View {
        VStack {
            Settings.Container(contentWidth: 400) {
                
                Settings.Section(label: {
                    Text("Popover style")
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
                }
                
                Settings.Section(label: {
                    Text("Popover background")
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
                }
                
            }
        }
    }
}

struct PopoverSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverSettingsView()
            .previewLayout(.device)
            .padding()
    }
}

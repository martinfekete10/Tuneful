//
//  MiniPlayerAppearanceView.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/01/2024.
//

import SwiftUI
import Settings

struct MiniPlayerAppearanceSettingsView: View {
    
    @AppStorage("miniPlayerBackground") var miniPlayerBackgroundAppStorage: BackgroundType = .albumArt
    @AppStorage("showPlayerWindow") var showPlayerWindowAppStorage: Bool = false
    @AppStorage("miniPlayerType") var miniPlayerTypeAppStorage: MiniPlayerType = .full
    
    // A bit of a hack, binded AppStorage variable doesn't refresh UI, first we read the app storage this way
    // and @AppStorage variable  is updated whenever the state changes using .onChange()
    @State var miniPlayerBackground: BackgroundType
    @State var showPlayerWindow: Bool
    @State var miniPlayerType: MiniPlayerType
    
    init() {
        @AppStorage("miniPlayerBackground") var miniPlayerBackgroundAppStorage: BackgroundType = .albumArt
        @AppStorage("showPlayerWindow") var showPlayerWindowAppStorage: Bool = false
        @AppStorage("miniPlayerType") var miniPlayerTypeAppStorage: MiniPlayerType = .full

        self.miniPlayerBackground = miniPlayerBackgroundAppStorage
        self.showPlayerWindow = showPlayerWindowAppStorage
        self.miniPlayerType = miniPlayerTypeAppStorage
    }
    
    var body: some View {
        VStack {
            Settings.Container(contentWidth: 500) {
                
                Settings.Section(label: {
                    Text("Show mini player window")
                }) {
                    Toggle(isOn: $showPlayerWindow) {
                        Text("")
                    }
                    .onChange(of: showPlayerWindow) { _ in
                        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayer), to: nil, from: nil)
                    }
                    .toggleStyle(.switch)
                }
                
                Settings.Section(label: {
                    Text("Mini player background")
                }) {
                    Picker("", selection: $miniPlayerBackground) {
                        ForEach(BackgroundType.allCases, id: \.self) { value in
                            Text(value.localizedName).tag(value)
                        }
                    }
                    .onChange(of: miniPlayerBackground) { newValue in
                        self.miniPlayerBackgroundAppStorage = miniPlayerBackground
                    }
                    .pickerStyle(.menu)
                    .frame(width: 200)
                }
                
                Settings.Section(label: {
                    Text("Window style")
                }) {
                    Picker(selection: $miniPlayerType, label: Text("")) {
                        Image(.fullMiniPlayer)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .tag(MiniPlayerType.full)
                        
                        Image(.fullMiniPlayer)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .tag(MiniPlayerType.albumArt)
                        
//                        Image(.fullMiniPlayer)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 150)
//                            .tag(MiniPlayerType.minimal)
                    }
                    .onChange(of: miniPlayerType) { newValue in
                        self.miniPlayerTypeAppStorage = miniPlayerType
                        NSApplication.shared.sendAction(#selector(AppDelegate.setupMiniPlayer), to: nil, from: nil)
                    }
                    .pickerStyle(.radioGroup)
                }
            }
        }
    }
}

struct MiniPlayerAppearanceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerAppearanceSettingsView()
            .previewLayout(.device)
            .padding()
    }
}

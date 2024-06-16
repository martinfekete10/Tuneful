//
//  MiniPlayerSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/01/2024.
//

import SwiftUI
import Settings

struct MiniPlayerSettingsView: View {
    
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
        VStack {
            Settings.Container(contentWidth: 400) {
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
                    Text("Mini player window always on top")
                }) {
                    Toggle(isOn: $miniPlayerWindowOnTop) {
                        Text("")
                    }
                    .onChange(of: miniPlayerWindowOnTop) { _ in
                        self.miniPlayerWindowOnTopAppStorage = miniPlayerWindowOnTop
                        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayerWindowLevel), to: nil, from: nil)
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
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                Settings.Section(label: {
                    Text("Window style")
                }) {
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
                }
            }
        }
    }
}

struct BorderModifier: ViewModifier {
    var selectedMiniPlayer: MiniPlayerType?
    var miniPlayerType: MiniPlayerType

    func body(content: Content) -> some View {
        content
            .border(selectedMiniPlayer == miniPlayerType ? Color.blue : Color.clear, width: 2)
    }
}

struct MiniPlayerAppearanceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerSettingsView()
            .previewLayout(.device)
            .padding()
    }
}

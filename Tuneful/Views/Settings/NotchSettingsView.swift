import SwiftUI
import Settings
import LaunchAtLogin
import Luminare

struct NotchSettingsView: View {
    
    @AppStorage("showNotchOnPlayPause") private var showNotchOnPlayPauseAppStorage = true

    @State private var showNotchOnPlayPause: Bool
    
    init() {
        @AppStorage("showNotchOnPlayPause") var showNotchOnPlayPauseAppStorage = true
        
        self.showNotchOnPlayPause = showNotchOnPlayPauseAppStorage
    }
    
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "") {
                LuminareSection("Display") {
                    LuminareToggle("Show on play/pause", isOn: $showNotchOnPlayPauseAppStorage)
                }
                .padding(.top, 10)
            }
        }
    }
    
}

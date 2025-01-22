//
//  AboutSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/01/2024.
//

import SwiftUI
import Settings

struct AcknowledgementsSettingsView: View {
    var body: some View {
        Settings.Container(contentWidth: Constants.settingsWindowWidth) {
            Settings.Section(title: "") {
                VStack {
                    Text("Tuneful uses the following open source libraries or their modifications")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                LuminareSection {
                    AcknowledgmentsView(
                        libraryName: "Luminare",
                        libraryUrl: "https://github.com/MrKai77/Luminare",
                        licenseName: "BSD 3-Clause License",
                        licenseUrl: "https://github.com/MrKai77/Luminare/blob/main/LICENSE.md"
                    )
                    
                    AcknowledgmentsView(
                        libraryName: "LaunchAtLogin",
                        libraryUrl: "https://github.com/sindresorhus/LaunchAtLogin-Legacy",
                        licenseName: "MIT license",
                        licenseUrl: "https://github.com/sindresorhus/LaunchAtLogin-Legacy/blob/main/license"
                    )
                    
                    AcknowledgmentsView(
                        libraryName: "Settings",
                        libraryUrl: "https://github.com/sindresorhus/Settings",
                        licenseName: "MIT license",
                        licenseUrl: "https://github.com/sindresorhus/Settings/blob/main/license"
                    )
                    
                    AcknowledgmentsView(
                        libraryName: "DynamicNotchKit",
                        libraryUrl: "https://github.com/MrKai77/DynamicNotchKit",
                        licenseName: "MIT license",
                        licenseUrl: "https://github.com/MrKai77/DynamicNotchKit/blob/main/LICENSE"
                    )
                }
            }
        }
    }
}

struct AcknowledgmentsView: View {
    var libraryName: String
    var libraryUrl: String
    var licenseName: String
    var licenseUrl: String
    
    var body: some View {
        HStack {
            Image(systemName: "book.pages.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Link(destination: URL(string: libraryUrl)!) {
                    Text(libraryName)
                        .font(.headline)
                }
                .buttonStyle(PressButtonStyle())
                
                Link(destination: URL(string: licenseUrl)!) {
                    Text(licenseName)
                        .font(.footnote)
                }
                .buttonStyle(PressButtonStyle())
            }
            
            Spacer()
        }
        .padding(2.5)
    }
}

#Preview {
    AboutSettingsView()
}

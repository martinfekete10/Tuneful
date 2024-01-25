//
//  AboutSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 12/01/2024.
//

import SwiftUI
import Settings

struct AboutSettingsView: View {
    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "", verticalAlignment: .center) {
                VStack(alignment: .center) {
                    Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text("Tuneful")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Version \(Constants.AppInfo.appVersion ?? "?")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Divider()
                    HStack {
                        Link("Support", destination: URL(string: "https://ko-fi.com/martinfekete")!)
                            .buttonStyle(.bordered)
                        Link("GitHub", destination: URL(string: "https://github.com/martinfekete10/Tuneful")!)
                            .buttonStyle(.bordered)
                        Link("Website", destination: URL(string: "https://martinfekete.com/Tuneful")!)
                            .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct AboutSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSettingsView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

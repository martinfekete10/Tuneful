//
//  OnboardingView.swift
//  Tuneful
//
//  Created by Martin Fekete on 03/08/2023.
//

import SwiftUI
import ScriptingBridge

struct OnboardingView: View {

    @AppStorage("viewedOnboarding") var viewedOnboarding: Bool = false
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.spotify
    
    private enum Steps {
      case onAppPicker, onDetails
    }
    
    // Navigation
    @State private var step: Steps = .onAppPicker
    
    // Onboarding alerts
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var finishedAlert = false
    
    private var name: Text {
        Text(connectedApp.localizedName)
    }
    
    var body: some View {
        
        HStack {
            
            VStack(alignment: .center) {
                VStack {
                    if step == .onAppPicker {
                        AppPicker(connectedApp: $connectedApp)
                    } else if step == .onDetails {
                        Details(connectedApp: $connectedApp, viewedOnboarding: $viewedOnboarding)
                    } else {
                        EmptyView()
                    }
                }
                .frame(width: 300, height: 160)
                .padding(.horizontal, 32)
                .animation(.spring(), value: step)
                
                Divider()
                
                HStack {
                    Button("Back") {
                        step = .onAppPicker
                    }
                    .disabled(step == .onAppPicker)
                    
                    if step == .onAppPicker {
                        Button("Continue") {
                            step = .onDetails
                        }
                        .keyboardShortcut(.defaultAction)
                    } else {
                        Button("Finish") {
                            NSApplication.shared.sendAction(#selector(AppDelegate.finishOnboarding), to: nil, from: nil)
                        }
                        .disabled(!finishedAlert)
                    }
                }
                .frame(width: 150, height: 50)
            }
            .frame(width: 250, height: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

struct AppPicker: View {
    
    @Binding var connectedApp: ConnectedApps
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Select the app you use")
                .font(.headline)
            Picker("", selection: $connectedApp) {
                ForEach(ConnectedApps.allCases, id: \.self) { value in
                    Text(value.localizedName).tag(value)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct Details: View {
    @Binding var connectedApp: ConnectedApps
    @Binding var viewedOnboarding: Bool
    
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showAlert = false
    @State private var success = false
    
    private var name: Text {
        Text(connectedApp.localizedName)
    }
    
    var body: some View {
        VStack {
            Text("""
                 Tuneful requires permission to control \(name) and display music data.
                 
                 Open \(name) and click 'Enable permissions' below and select OK in the alert that is presented.
             """)
            .font(.caption2)
            .multilineTextAlignment(.center)
            
            Button("Enable permissions") {
                let consent = Helper.promptUserForConsent(for: connectedApp == .spotify ? Constants.Spotify.bundleID : Constants.AppleMusic.bundleID)
                switch consent {
                case .granted:
                    alertTitle = Text("You are all set up!")
                    alertMessage = Text("Start playing a song!")
                    success = true
                    showAlert = true
                    viewedOnboarding = true
                case .closed:
                    alertTitle = Text("\(name) is not open")
                    alertMessage = Text("Please open \(name) to enable permissions")
                    showAlert = true
                    success = false
                case .denied:
                    alertTitle = Text("Permission denied")
                    alertMessage = Text("Please go to System Settings > Privacy & Security > Automation, and check \(name) under Tuneful")
                    showAlert = true
                    success = false
                case .notPrompted:
                    return
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: alertTitle, message: alertMessage, dismissButton: .default(Text("Got it!")) {
                    if success {
                        NSApplication.shared.sendAction(#selector(AppDelegate.finishOnboarding), to: nil, from: nil)
                    }
                })
            }
        }
    }
}

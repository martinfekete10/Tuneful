//
//  OnboardingView.swift
//  Tuneful
//
//  Created by Martin Fekete on 03/08/2023.
//

import SwiftUI
import ScriptingBridge
import KeyboardShortcuts
import Luminare

struct OnboardingView: View {
    
    private enum Steps {
      case onAppPicker, onDetails, allDone
    }
    
    @AppStorage("viewedShortcutsSetup") var viewedShortcutsSetup: Bool = false
    
    @State private var step: Steps = .onAppPicker
    @State private var finishedAlert = false
    
    var body: some View {
        VStack(alignment: .center) {
                VStack {
                    VStack {
                        Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .padding(.bottom, 10)
                        
                        if step == .onAppPicker {
                            Text("1. Preferred Music App")
                                .font(.title2)
                                .fontWeight(.semibold)
                        } else if step == .onDetails {
                            Text("2. Permissions")
                                .font(.title2)
                                .fontWeight(.semibold)
                        } else if step == .allDone {
                            Text("3. All Done!")
                                .font(.title2)
                                .fontWeight(.semibold)
                        } else {
                            EmptyView()
                        }
                    }
                    .padding(.bottom, 10)
                    
                    if step == .onAppPicker {
                        AppPicker()
                    } else if step == .onDetails {
                        Details(finishedAlert: $finishedAlert)
                    } else if step == .allDone {
                        AllDone()
                    } else {
                        EmptyView()
                    }
                }
                .frame(width: 400, height: 250)
                .padding(.horizontal, 30)
                .animation(Constants.SongTransitionAnimation, value: step)
                
                Divider()
                    .frame(width: 300)
                
                HStack {
                    if step == .onDetails {
                        Button("Back") {
                            step = .onAppPicker
                        }
                        .buttonStyle(LuminareCompactButtonStyle())
                    } else if step == .allDone {
                        Button("Back") {
                            step = .onDetails
                        }
                        .buttonStyle(LuminareCompactButtonStyle())
                    } else {
                        Button("Back") {
                            step = .onAppPicker
                        }
                        .buttonStyle(LuminareCompactButtonStyle())
                        .disabled(step == .onAppPicker)
                    }
                    
                    if step == .onAppPicker {
                        Button("Continue") {
                            step = .onDetails
                        }
                        .buttonStyle(LuminareCompactButtonStyle())
                        .keyboardShortcut(.defaultAction)
                    } else if step == .onDetails {
                        Button("Continue") {
                            step = .allDone
                        }
                        .buttonStyle(LuminareCompactButtonStyle())
                        .keyboardShortcut(.defaultAction)
                        .disabled(!finishedAlert)
                    } else {
                        Button("Finish") {
                            self.viewedShortcutsSetup = true
                            NSApplication.shared.sendAction(#selector(AppDelegate.finishOnboarding), to: nil, from: nil)
                        }
                        .buttonStyle(LuminareCompactButtonStyle())
                    }
                }
                .frame(width: 150, height: 50)
            }
            .frame(width: 600, height: 500)
            .background(
                VisualEffectView(material: .popover, blendingMode: .behindWindow)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
    }
}

struct AppPicker: View {
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.appleMusic
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(ConnectedApps.allCases, id: \.rawValue) { app in
                    LuminareSection() {
                        Button(action: {
                            connectedApp = app
                        }) {
                            app.getIcon
                                .resizable()
                                .frame(width: 70, height: 70)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .disabled(!app.selectable)
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 80, height: 80)
                    }
                    .if(connectedApp == app) { button in
                        button.overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.secondary, lineWidth: 2)
                        )
                    }
                    
                    if !ConnectedApps.spotify.selectable {
                        Text("Apple Music is the only avaiable music app as Spotify was not found. It should be located at the top level of Applications folder.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(width: 250)
    }
}

struct Details: View {
    @AppStorage("viewedOnboarding") var viewedOnboarding: Bool = false
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.appleMusic
    
    @Binding var finishedAlert: Bool
    
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
            .font(.caption)
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
                    alertTitle = Text("\(name) is not opened")
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
                        finishedAlert = true
                    }
                })
            }
        }
    }
}

struct AllDone: View {
    var body: some View {
        VStack {
            Text("""
                 To fully customize Tuneful, right-click Tuneful icon in menu bar and go to Settings.
             """)
            .font(.caption)
            .multilineTextAlignment(.center)
        }
    }
}

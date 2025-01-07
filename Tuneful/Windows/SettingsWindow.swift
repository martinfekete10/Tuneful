//
//  SettingsWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 01/12/2024.
//

import SwiftUI

public class SettingsWindow: NSWindow, ObservableObject {
    public init() {
        super.init(
            contentRect: .zero,
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        
        let hostingView = NSHostingView(
            rootView: SettingsView()
        )
        
        backgroundColor = .clear
        contentView = hostingView
        contentView?.wantsLayer = true
        ignoresMouseEvents = false
        isOpaque = false
        hasShadow = true
        titleVisibility = .hidden
        
        toolbarStyle = .unified
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        
        let customToolbar = NSToolbar()
        customToolbar.showsBaselineSeparator = false
        toolbar = customToolbar
        
        center()
    }
}

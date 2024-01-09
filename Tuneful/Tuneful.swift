//
//  TunefulApp.swift
//  Tuneful
//
//  Created by Martin Fekete on 27/07/2023.
//

import SwiftUI
import Sparkle

import Settings

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @AppStorage("showSongInfo") var showSongInfo: Bool = true
    @AppStorage("showPlayerWindow") var showPlayerWindow: Bool = false
    @AppStorage("viewedOnboarding") var viewedOnboarding: Bool = false
    
    private var onboardingWindow: OnboardingWindow!
    private var miniPlayerWindow: MiniPlayerWindow!
    private var popover: NSPopover!
    
    // Popover
    static let popoverWidth: CGFloat = 210
    static let popoverHeight: CGFloat = 370
    
    // Status bar
    private var statusBarItem: NSStatusItem!
    private var statusBarMenu: NSMenu!
    
    // ViewModels
    private var playerManager = PlayerManager()
    private var statusBarItemManager = StatusBarItemManager()
    
    // Settings
    let GeneralSettingsViewController: () -> SettingsPane = {
        let paneView = Settings.Pane(
            identifier: .general,
            title: "General        ",
            toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General settings")!
        ) {
            GeneralSettingsView()
        }

        return Settings.PaneHostingController(pane: paneView)
    }
    
    let AppearanceSettingsViewController: () -> SettingsPane = {
        let paneView = Settings.Pane(
            identifier: .appearance,
            title: "Appearance",
            toolbarIcon: NSImage(systemSymbolName: "paintbrush.pointed.fill", accessibilityDescription: "Appearance settings")!
        ) {
            AppearanceSettingsView()
        }

        return Settings.PaneHostingController(pane: paneView)
    }
    
    let AboutSettingsViewController: () -> SettingsPane = {
        let paneView = Settings.Pane(
            identifier: .about,
            title: "About      ",
            toolbarIcon: NSImage(systemSymbolName: "info.circle", accessibilityDescription: "About settings")!
        ) {
            AboutSettingsView()
        }

        return Settings.PaneHostingController(pane: paneView)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatusBarItem),
            name: NSNotification.Name("TrackChanged"),
            object: nil
        )
        
        // Onboarding
        if !viewedOnboarding {
            self.showOnboarding()
        } else {
            self.mainSetup()
        }
    }
    
    private func mainSetup() {
        setupPopover()
        setupMiniPlayer()
        setupMenuBar()
    }
    
    // MARK: - Menu bar
    
    private func setupMenuBar() {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        statusBarMenu = NSMenu()
        statusBarMenu.delegate = self
        
        statusBarMenu.addItem(
            withTitle: "Show mini player",
            action: #selector(toggleState),
            keyEquivalent: ""
        )
        .state = showPlayerWindow ? .on : .off
        
        statusBarMenu.addItem(
            withTitle: "Preferences...",
            action: #selector(showPreferences),
            keyEquivalent: ""
        )
        
        statusBarMenu.addItem(.separator())
        
        // TODO: add link to about page
        statusBarMenu.addItem(
            withTitle: "About...",
            action: #selector(openURL),
            keyEquivalent: ""
        )
        
        let updates = NSMenuItem(
            title: "Check for updates...",
            action: #selector(SUUpdater.checkForUpdates(_:)),
            keyEquivalent: ""
        )
        updates.target = SUUpdater.shared()
        statusBarMenu.addItem(updates)
        
        statusBarMenu.addItem(.separator())
        
        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(NSApplication.terminate),
            keyEquivalent: ""
        )
        
        if let statusBarItemButton = statusBarItem.button {
            statusBarItemButton.action = #selector(didClickStatusBarItem)
            statusBarItemButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    @objc func didClickStatusBarItem(_ sender: AnyObject?) {
        guard let event = NSApp.currentEvent else { return }
        
        switch event.type {
        case .rightMouseUp:
            statusBarItem.menu = statusBarMenu
            statusBarItem.button?.performClick(nil)
        default:
            showPopover(statusBarItem.button)
        }
    }
    
    @IBAction func toggleState(_ sender: NSMenuItem) {
        if sender.state == .on {
            sender.state = .off
            showPlayerWindow = false
            playerManager.timerStopSignal.send()
            miniPlayerWindow.close()
        } else {
            sender.state = .on
            showPlayerWindow = true
            setupMiniPlayer()
        }
    }

    @IBAction func openURL(_ sender: AnyObject) {
        let url = URL(string: "https://github.com/martinfekete10/Tuneful")
        NSWorkspace.shared.open(url!)
    }
    
    func menuDidClose(_: NSMenu) {
        statusBarItem.menu = nil
    }
    
    // MARK: - Status bar item title
    
    @objc func updateStatusBarItem(_ notification: NSNotification) {
        let title = self.statusBarItemManager.getStatusBarTrackInfo(track: playerManager.track)
        let image = self.statusBarItemManager.getImage(albumArt: playerManager.track.albumArt)
        
        if let button = self.statusBarItem.button {
            button.image = image
            button.title = String(title)
        }
    }

    
    // MARK: - Popover
    
    private func setupPopover() {
        let frameSize = NSSize(width: 210, height: 310)
        
        // Initialize ContentView
        let rootView = PopoverView()
            .environmentObject(self.playerManager)
        let hostedContentView = NSHostingView(rootView: rootView)
        hostedContentView.frame = NSRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        // Initialize Popover
        popover = NSPopover()
        popover.contentSize = frameSize
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = hostedContentView
        popover.contentViewController?.view.window?.makeKey()
        
        playerManager.popoverIsShown = popover.isShown
    }
    
    // Toggle open and close of popover
    @objc func showPopover(_ sender: NSStatusBarButton?) {
        guard let statusBarItemButton = sender else { return }
        
        popover.show(relativeTo: statusBarItemButton.bounds, of: statusBarItemButton, preferredEdge: .minY)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    // MARK: - Window handlers
    
    @objc func setupMiniPlayer() {
        if miniPlayerWindow == nil {
            miniPlayerWindow = MiniPlayerWindow()
            let rootView = MiniPlayerView()
                .environmentObject(self.playerManager)
            let hostedOnboardingView = NSHostingView(rootView: rootView)
            miniPlayerWindow.contentView = hostedOnboardingView
        }
        
        miniPlayerWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        playerManager.timerStartSignal.send()
        
        if !showPlayerWindow {
            playerManager.timerStopSignal.send()
            miniPlayerWindow.close()
        }
    }
    
    @objc func showPreferences(_ sender: AnyObject) {
        SettingsWindowController(
            panes: [GeneralSettingsViewController(), AppearanceSettingsViewController(), AboutSettingsViewController()],
            style: .toolbarItems,
            animated: true,
            hidesToolbarForSingleItem: true
        ).show()
    }
    
    public func showOnboarding() {
        if onboardingWindow == nil {
            onboardingWindow = OnboardingWindow()
            let rootView = OnboardingView()
            let hostedOnboardingView = NSHostingView(rootView: rootView)
            onboardingWindow.contentView = hostedOnboardingView
        }
        
        onboardingWindow.center()
        onboardingWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    @objc func finishOnboarding(_ sender: AnyObject) {
        onboardingWindow.close()
        
        // After finishing onboarding, we want to setup popover and mini-player window
        self.mainSetup()
    }
}

@main
struct Tuneful: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

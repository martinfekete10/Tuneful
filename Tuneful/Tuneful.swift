//
//  TunefulApp.swift
//  Tuneful
//
//  Created by Martin Fekete on 27/07/2023.
//

import SwiftUI
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @AppStorage("showPlayerWindow") var showPlayerWindow: Bool = false
    @AppStorage("viewedOnboarding") var viewedOnboarding: Bool = false
    
    private var contentViewModel: ContentViewModel!
    private var onboardingWindow: OnboardingWindow!
    private var miniPlayerWindow: MiniPlayerWindow!
    private var preferencesWindow: PreferencesWindow!
    private var featureRequestWindow: PreferencesWindow!
    private var popover: NSPopover!
    
    // Popover
    static let popoverWidth: CGFloat = 210
    static let popoverHeight: CGFloat = 370
    
    // Status bar
    private var statusBarItem: NSStatusItem!
    private var statusBarMenu: NSMenu!
    
    // Enviroment object
    @Published var popoverIsShown: Bool!
    
    // Auto-update
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let updaterController: SPUStandardUpdaterController
    
    override init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updaterController.updater)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        self.contentViewModel = ContentViewModel()
        
        // Onboarding
        if !viewedOnboarding {
            self.showOnboarding()
        } else {
            self.mainSetup()
        }
    }
    
    private func mainSetup() {
        // Views
        setupPopover()
        setupMiniPlayer()
        setupMenuBar()
    }
    
    // MARK: - Menu bar
    
    private func setupMenuBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "music.quarternote.3", accessibilityDescription: "Floating Music")
        }
        
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
            action: #selector(NSApplication.terminate),
            keyEquivalent: ""
        )
        
        let updates = NSMenuItem(
            title: "Check for updates...",
            action: #selector(SUUpdater.checkForUpdates(_:)),
            keyEquivalent: "")
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
            contentViewModel.timerStopSignal.send()
            miniPlayerWindow.close()
        } else {
            sender.state = .on
            showPlayerWindow = true
            setupMiniPlayer()
        }
    }
    
    func menuDidClose(_: NSMenu) {
        statusBarItem.menu = nil
    }
    
    // MARK: - Popover
    
    private func setupPopover() {
        let frameSize = NSSize(width: 210, height: 310)
        
        // Initialize ContentView
        let rootView = PopoverView()
            .environmentObject(self.contentViewModel)
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
        
        contentViewModel.popoverIsShown = popover.isShown
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
                .environmentObject(self.contentViewModel)
            let hostedOnboardingView = NSHostingView(rootView: rootView)
            miniPlayerWindow.contentView = hostedOnboardingView
        }
        
        miniPlayerWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        contentViewModel.timerStartSignal.send()
        
        if !showPlayerWindow {
            contentViewModel.timerStopSignal.send()
            miniPlayerWindow.close()
        }
    }
    
    @objc func showPreferences(_ sender: AnyObject) {
        if preferencesWindow == nil {
            preferencesWindow = PreferencesWindow()
            let preferencesView = PreferencesView(parentWindow: preferencesWindow)
            let hostedPrefView = NSHostingView(rootView: preferencesView)
            preferencesWindow.contentView = hostedPrefView
        }
        
        preferencesWindow.center()
        preferencesWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
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

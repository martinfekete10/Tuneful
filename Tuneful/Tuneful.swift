//
//  TunefulApp.swift
//  Tuneful
//
//  Created by Martin Fekete on 27/07/2023.
//

import SwiftUI
import Sparkle
import KeyboardShortcuts
import Settings

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @AppStorage("popoverType") var popoverType: PopoverType = .full
    @AppStorage("miniPlayerType") var miniPlayerType: MiniPlayerType = .minimal
    @AppStorage("showPlayerWindow") var showPlayerWindow: Bool = true
    @AppStorage("viewedOnboarding") var viewedOnboarding: Bool = false
    @AppStorage("viewedShortcutsSetup") var viewedShortcutsSetup: Bool = false
    @AppStorage("miniPlayerWindowOnTop") var miniPlayerWindowOnTop: Bool = true
    @AppStorage("hideMenuBarItemWhenNotPlaying") var hideMenuBarItemWhenNotPlaying: Bool = false
    @AppStorage("connectedApp") var connectedApp = ConnectedApps.spotify {
        didSet {
            self.updateMenuItemsState()
        }
    }
    
    private var onboardingWindow: OnboardingWindow!
    private var miniPlayerWindow: MiniPlayerWindow = MiniPlayerWindow()
    private var popover: NSPopover!
    
    // Popover
    static let popoverWidth: CGFloat = 210
    static let popoverHeight: CGFloat = 370
    
    // Status bar
    private var statusBarItem: NSStatusItem!
    public var statusBarMenu: NSMenu!
    
    // Managers
    private var playerManager: PlayerManager!
    private var statusBarItemManager: StatusBarItemManager!
    private var statusBarPlaybackManager: StatusBarPlaybackManager!
    
    // Settings
    let GeneralSettingsViewController: () -> SettingsPane = {
        let paneView = Settings.Pane(
            identifier: .general,
            title: "General",
            toolbarIcon: NSImage(systemSymbolName: "switch.2", accessibilityDescription: "General settings")!
        ) {
            GeneralSettingsView()
        }
        
        return Settings.PaneHostingController(pane: paneView)
    }
    
    let PopoverSettingsViewController: () -> SettingsPane = {
        let paneView = Settings.Pane(
            identifier: .popover,
            title: "Popover",
            toolbarIcon: NSImage(systemSymbolName: "rectangle.portrait", accessibilityDescription: "Popover settings")!
        ) {
            PopoverSettingsView()
        }
        
        return Settings.PaneHostingController(pane: paneView)
    }
    
    let MenuBarSettingsViewController: () -> SettingsPane = {
        let paneView = Settings.Pane(
            identifier: .menuBar,
            title: "Menu bar",
            toolbarIcon: NSImage(systemSymbolName: "menubar.rectangle", accessibilityDescription: "Menu bar settings")!
        ) {
            MenuBarSettingsView()
        }
        
        return Settings.PaneHostingController(pane: paneView)
    }
    
    let MiniPlayerSettingsViewController: () -> SettingsPane = {
        let paneView = Settings.Pane(
            identifier: .miniPlayer,
            title: "Mini player",
            toolbarIcon: NSImage(systemSymbolName: "play.rectangle.on.rectangle.fill", accessibilityDescription: "Mini player settings")!
        ) {
            MiniPlayerSettingsView()
        }
        
        return Settings.PaneHostingController(pane: paneView)
    }
    
    let KeyboardShortcutsSettingsViewController: () -> SettingsPane = {
        let paneView = Settings.Pane(
            identifier: .keyboard,
            title: "Keyboard",
            toolbarIcon: NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Keyboard shortcuts settings")!
        ) {
            KeyboardShortcutsSettingsView()
        }
        
        return Settings.PaneHostingController(pane: paneView)
    }
    
    let AboutSettingsViewController: () -> SettingsPane = {
        let paneView = Settings.Pane(
            identifier: .about,
            title: "About",
            toolbarIcon: NSImage(systemSymbolName: "info.circle", accessibilityDescription: "About settings")!
        ) {
            AboutSettingsView()
        }
        
        return Settings.PaneHostingController(pane: paneView)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        self.playerManager = PlayerManager()
        self.statusBarItemManager = StatusBarItemManager()
        self.statusBarPlaybackManager = StatusBarPlaybackManager(playerManager: playerManager)
        
//        if let bundleID = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundleID)
//        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateStatusBarItem),
            name: NSNotification.Name("UpdateMenuBarItem"),
            object: nil
        )
        
        if !viewedOnboarding {
            self.showOnboarding()
        } else {
            self.mainSetup()
        }
    }
    
    private func mainSetup() {
        self.setupPopover()
        self.setupMiniPlayer()
        self.setupMenuBar()
        self.updateStatusBarItem(nil)
        self.setupKeyboardShortcuts()
    }
    
    // MARK: - Music player
    
    private func changeMusicPlayer() {
        switch connectedApp {
        case .spotify:
            self.connectedApp = .appleMusic
        case .appleMusic:
            self.connectedApp = .spotify
        }
    }
    
    @objc private func setSpotify() {
        if self.connectedApp == .spotify {
            return
        }
        
        self.connectedApp = .spotify
    }
    
    @objc private func setAppleMusic() {
        if self.connectedApp == .appleMusic {
            return
        }
        
        self.connectedApp = .appleMusic
    }
    
    func updateMenuItemsState() {
        if let menuItem = statusBarMenu.item(withTitle: "Music player")?.submenu {
            if let spotifyMenuItem = menuItem.item(withTitle: "Spotify") {
                spotifyMenuItem.state = (connectedApp == .spotify) ? .on : .off
            }
            
            if let appleMusicMenuItem = menuItem.item(withTitle: "Apple Music") {
                appleMusicMenuItem.state = (connectedApp == .appleMusic) ? .on : .off
            }
        }
    }
    
    // MARK: - Keyboard shortcuts
    
    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .playPause) {
            self.playerManager.togglePlayPause()
        }
        
        KeyboardShortcuts.onKeyUp(for: .nextTrack) {
            self.playerManager.nextTrack()
        }
        
        KeyboardShortcuts.onKeyUp(for: .previousTrack) {
            self.playerManager.previousTrack()
        }
        
        KeyboardShortcuts.onKeyUp(for: .showMiniPlayer) {
            self.toggleMiniPlayer()
        }
        
        KeyboardShortcuts.onKeyUp(for: .changeMusicPlayer) {
            self.changeMusicPlayer()
        }
    }
    
    // MARK: - Menu bar
    
    private func setupMenuBar() {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        statusBarMenu = NSMenu()
        statusBarMenu.delegate = self
        
        statusBarMenu.addItem(
            withTitle: "Show mini player",
            action: #selector(showHideMiniPlayer),
            keyEquivalent: ""
        )
        .state = showPlayerWindow ? .on : .off
        
        let switchPlayerMenuItem = NSMenuItem(title: "Music player", action: nil, keyEquivalent: "")
        let switchPlayerMenu = NSMenu()
        switchPlayerMenu
            .addItem(withTitle: "Spotify", action: #selector(setSpotify), keyEquivalent: "")
            .state = self.connectedApp == .spotify ? .on : .off
        switchPlayerMenu
            .addItem(withTitle: "Apple Music", action: #selector(setAppleMusic), keyEquivalent: "")
            .state = self.connectedApp == .appleMusic ? .on : .off
        switchPlayerMenuItem.submenu = switchPlayerMenu
        statusBarMenu.addItem(switchPlayerMenuItem)
        
        statusBarMenu.addItem(.separator())
        
        statusBarMenu.addItem(
            withTitle: "Settings...",
            action: #selector(openSettings),
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
            togglePopover(statusBarItem.button)
        }
    }
    
    @objc func toggleMiniPlayer() {
        self.showHideMiniPlayer(self.statusBarMenu.item(withTitle: "Show mini player")!)
    }
    
    @IBAction func showHideMiniPlayer(_ sender: NSMenuItem) {
        if sender.state == .on {
            sender.state = .off
            self.showPlayerWindow = false
            self.playerManager.timerStopSignal.send()
            self.miniPlayerWindow.close()
        } else {
            sender.state = .on
            self.showPlayerWindow = true
            self.setupMiniPlayer()
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
    
    @objc func updateStatusBarItem(_ notification: NSNotification?) {
        guard viewedOnboarding else { return }
        
        var playerAppIsRunning = playerManager.isRunning
        if notification?.userInfo?["PlayerAppIsRunning"] != nil {
            playerAppIsRunning = notification?.userInfo?["PlayerAppIsRunning"] as? Bool == true
        }
        
        let menuBarView = self.statusBarItemManager.getMenuBarView(
            track: playerManager.track,
            playerAppIsRunning: playerAppIsRunning,
            isPlaying: playerManager.isPlaying
        )
        
        if let button = self.statusBarItem.button {
            button.subviews.forEach { $0.removeFromSuperview() }
            button.addSubview(menuBarView)
            button.frame = menuBarView.frame
        }
        
        if hideMenuBarItemWhenNotPlaying && (!playerManager.isRunning || !playerManager.isPlaying) {
            self.statusBarItem.isVisible = false
        } else {
            self.statusBarItem.isVisible = true
        }
        
        self.statusBarPlaybackManager.updateStatusBarPlaybackItem(playerAppIsRunning: playerAppIsRunning)
        self.statusBarPlaybackManager.toggleStatusBarVisibility()
    }
    
    @objc func toggleMenuBarItemVisibility() {
        if hideMenuBarItemWhenNotPlaying && (!playerManager.isRunning || !playerManager.isPlaying) {
            self.statusBarItem.isVisible = false
        } else {
            self.statusBarItem.isVisible = true
        }
    }
    
    @objc func menuBarPlaybackControls() {
        self.statusBarPlaybackManager.toggleStatusBarVisibility()
    }
    
    
    // MARK: - Popover
    
//    @objc func setupPopover() {
//        let frameSize = NSSize(width: 210, height: 310)
//
//        switch popoverType {
//        case .full:
//            <#code#>
//        case .minimal:
//            <#code#>
//        }
//        let rootView = PopoverView()
//            .environmentObject(self.playerManager)
//        let hostedContentView = NSHostingView(rootView: rootView)
//        hostedContentView.frame = NSRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
//        
//        popover = NSPopover()
//        popover.contentSize = frameSize
//        popover.behavior = .transient
//        popover.animates = true
//        popover.contentViewController = NSViewController()
//        popover.contentViewController?.view = hostedContentView
//        popover.contentViewController?.view.window?.makeKey()
//        
//        playerManager.popoverIsShown = popover.isShown
//    }
    
    @objc func setupPopover() {
        let frameSize: NSSize
        let rootView: AnyView
        
        switch popoverType {
        case .full:
            frameSize = NSSize(width: 210, height: 310)
            rootView = AnyView(PopoverView().environmentObject(self.playerManager))
        case .minimal:
            frameSize = NSSize(width: 150, height: 200)
            rootView = AnyView(CompactPopoverView().environmentObject(self.playerManager))
        }
        
        let hostedContentView = NSHostingView(rootView: rootView)
        hostedContentView.frame = NSRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        popover = NSPopover()
        popover.contentSize = frameSize
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = hostedContentView
        popover.contentViewController?.view.window?.makeKey()
        
        playerManager.popoverIsShown = popover.isShown
    }

    
    @objc func togglePopover(_ sender: NSStatusBarButton?) {
        guard let statusBarItemButton = sender else { return }

        if popover.isShown {
            popover.close()
        } else {
            popover.show(relativeTo: statusBarItemButton.bounds, of: statusBarItemButton, preferredEdge: .minY)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
    
    // MARK: - Mini player
    
    @objc func setupMiniPlayer() {
        let originalWindowPosition = miniPlayerWindow.frame.origin
        let windowPosition = CGPoint(x: originalWindowPosition.x, y: originalWindowPosition.y + 10) // Not sure why, but everytime this function is called, window moves down a few pixels, thus this ugly workaround
        
        switch miniPlayerType {
        case .full:
            setupMiniPlayerWindow(
                size: NSSize(width: 300, height: 145),
                position: windowPosition,
                view: MiniPlayerView(parentWindow: miniPlayerWindow)
            )
        case .minimal:
            setupMiniPlayerWindow(
                size: NSSize(width: 145, height: 145),
                position: windowPosition,
                view: CompactMiniPlayerView(parentWindow: miniPlayerWindow)
            )
        }
        
        miniPlayerWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        playerManager.timerStartSignal.send()
        
        if !showPlayerWindow {
            playerManager.timerStopSignal.send()
            miniPlayerWindow.close()
        }
    }
    
    @objc func toggleMiniPlayerWindowLevel() {
        if self.miniPlayerWindowOnTop {
            self.miniPlayerWindow.level = .floating
        } else {
            self.miniPlayerWindow.level = .normal
        }
    }
    
    private func setupMiniPlayerWindow<Content: View>(size: NSSize, position: CGPoint, view: Content) {
        DispatchQueue.main.async {
            self.miniPlayerWindow.setFrame(NSRect(origin: position, size: size), display: true, animate: true)
        }
        
        let rootView = view.cornerRadius(15).environmentObject(self.playerManager)
        let hostedOnboardingView = NSHostingView(rootView: rootView)
        miniPlayerWindow.contentView = hostedOnboardingView
    }
    
    // MARK: - Settings
    
    @objc func openSettings(_ sender: AnyObject) {
        SettingsWindowController(
            panes: [
                GeneralSettingsViewController(),
                PopoverSettingsViewController(),
                MenuBarSettingsViewController(),
                MiniPlayerSettingsViewController(),
                KeyboardShortcutsSettingsViewController(),
                AboutSettingsViewController()
            ],
            style: .toolbarItems,
            animated: true,
            hidesToolbarForSingleItem: true
        ).show()
    }
    
    @objc func openMiniPlayerAppearanceSettings(_ sender: AnyObject) {
        SettingsWindowController(
            panes: [
                GeneralSettingsViewController(),
                PopoverSettingsViewController(),
                MenuBarSettingsViewController(),
                MiniPlayerSettingsViewController(),
                KeyboardShortcutsSettingsViewController(),
                AboutSettingsViewController()
            ],
            style: .toolbarItems,
            animated: true,
            hidesToolbarForSingleItem: true
        ).show(pane: .miniPlayer)
    }
    
    // MARK: - Setup
    
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

//
//  DynamicNotch.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import Combine
import SwiftUI

// MARK: - DynamicNotch

public class DynamicNotch<Content>: ObservableObject where Content: View {
    public var windowController: NSWindowController? // Make public in case user wants to modify the NSPanel
    
    // Player manager
    @Published var playerManager: PlayerManager

    // Content Properties
    @Published var content: () -> Content
    @Published var contentID: UUID
    @Published var isVisible: Bool = false // Used to animate the fading in/out of the user's view
    @Published var isNotificationVisible: Bool = false // Used to animate the fading in/out of the user's view

    // Notch Size
    @Published var notchWidth: CGFloat = 0
    @Published var notchHeight: CGFloat = 0

    // Notch Closing Properties
    @Published var isMouseInside: Bool = false
    
    private var timer: Timer?
    var workItem: DispatchWorkItem?
    private var subscription: AnyCancellable?

    // Notch Style
    private var notchStyle: Style = .notch
    public enum Style {
        case notch
        case floating
        case auto
    }

    // Animation
    private var maxAnimationDuration: Double = 0.8 // This is a timer to deinit the window after closing
    var animation: Animation {
        if #available(macOS 14.0, *), notchStyle == .notch {
            Animation.spring(.bouncy(duration: 0.4))
        } else {
            Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
        }
    }

    /// Makes a new DynamicNotch with custom content and style.
    /// - Parameters:
    ///   - content: A SwiftUI View
    ///   - style: The popover's style. If unspecified, the style will be automatically set according to the screen.
    public init(contentID: UUID = .init(), style: DynamicNotch.Style = .auto, playerManager: PlayerManager, @ViewBuilder content: @escaping () -> Content) {
        self.contentID = contentID
        self.content = content
        self.notchStyle = style
        self.playerManager = playerManager
        self.subscription = NotificationCenter.default
            .publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                guard let self, let screen = NSScreen.screens.first else { return }
                initializeWindow(screen: screen)
            }
    }
}

// MARK: - Public

public extension DynamicNotch {
    
    func updateNotchWidth(isPlaying: Bool) {
        withAnimation(self.animation) {
            if isPlaying {
                self.refreshNotchSize(NSScreen.screens[0])
                self.notchWidth += 90
            } else {
                self.refreshNotchSize(NSScreen.screens[0])
            }
        }
    }

    /// Set this DynamicNotch's content.
    /// - Parameter content: A SwiftUI View
    func setContent(contentID: UUID = .init(), content: @escaping () -> Content) {
        self.content = content
        self.contentID = .init()
    }
    
    /// Set this DynamicNotch's content.
    /// - Parameter content: A SwiftUI View
    func refreshContent(contentID: UUID = .init()) {
        self.contentID = .init()
    }

    /// Show the DynamicNotch.
    /// - Parameters:
    ///   - screen: Screen to show on. Default is the primary screen.
    ///   - time: Time to show in seconds. If 0, the DynamicNotch will stay visible until `hide()` is called.
    func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) {
        func scheduleHide(_ time: Double) {
            let workItem = DispatchWorkItem { self.hide() }
            self.workItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: workItem)
        }

        guard !isVisible else {
            if time > 0 {
                self.workItem?.cancel()
                scheduleHide(time)
            }
            return
        }
        timer?.invalidate()

        initializeWindow(screen: screen)

        DispatchQueue.main.async {
            withAnimation(self.animation) {
                self.isVisible = true
                self.isNotificationVisible = true
            }
        }

        if time != 0 {
            self.workItem?.cancel()
            scheduleHide(time)
        }
    }

    /// Hide the DynamicNotch.
    func hide() {
        guard isVisible else { return }

        guard !isMouseInside else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.hide()
            }
            return
        }

        withAnimation(animation) {
            self.isVisible = false
            self.isNotificationVisible = false
        }
    }

    /// Toggle the DynamicNotch's visibility.
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    /// Check if the cursor is inside the screen's notch area.
    /// - Returns: If the cursor is inside the notch area.
    static func checkIfMouseIsInNotch() -> Bool {
        guard let screen = NSScreen.screenWithMouse else {
            return false
        }

        let notchWidth: CGFloat = 300
        let notchHeight: CGFloat = screen.frame.maxY - screen.visibleFrame.maxY // menubar height

        let notchFrame = screen.notchFrame ?? NSRect(
            x: screen.frame.midX - (notchWidth / 2),
            y: screen.frame.maxY - notchHeight,
            width: notchWidth,
            height: notchHeight
        )

        return notchFrame.contains(NSEvent.mouseLocation)
    }
}

// MARK: - Private

extension DynamicNotch {

    func refreshNotchSize(_ screen: NSScreen) {
        if let notchSize = screen.notchSize {
            notchWidth = notchSize.width
            notchHeight = notchSize.height
        } else {
            notchWidth = 300
            notchHeight = screen.frame.maxY - screen.visibleFrame.maxY // menubar height
        }
    }

    func initializeWindow(screen: NSScreen) {
        // so that we don't have a duplicate window
        deinitializeWindow()

        refreshNotchSize(screen)

        let view: NSView = {
            switch notchStyle {
            case .notch:
                NSHostingView(rootView: NotchView(dynamicNotch: self).foregroundStyle(.white))
            case .floating:
                NSHostingView(rootView: NotchlessView(dynamicNotch: self))
            case .auto:
                screen.hasNotch
                    ? NSHostingView(rootView: NotchView(dynamicNotch: self).foregroundStyle(.white))
                    : NSHostingView(rootView: NotchlessView(dynamicNotch: self))
            }
        }()

        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.hasShadow = false
        panel.backgroundColor = .clear
        panel.level = .screenSaver
        panel.collectionBehavior = .canJoinAllSpaces
        panel.contentView = view
        panel.orderFrontRegardless()
        panel.setFrame(screen.frame, display: false)

        windowController = .init(window: panel)
    }

    func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }
    
    // Handle mouse events
    private func handleMouseEntered() {
        print("Perform action on mouse hover")
        // Add your method execution here
    }

    private func handleMouseExited() {
        print("Perform action on mouse exit")
        // Optional: Add exit handling here
    }
}

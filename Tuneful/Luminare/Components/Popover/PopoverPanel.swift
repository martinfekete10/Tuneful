//
//  PopoverPanel.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//

import SwiftUI

public class PopoverPanel: NSPanel, ObservableObject {
    public static let cornerRadius: CGFloat = 12
    public static let contentPadding: CGFloat = 6
    public static let sectionPadding: CGFloat = 8

    @Published public var closeHandler: (() -> ())?

    public init() {
        super.init(
            contentRect: .zero,
            styleMask: [.fullSizeContentView, .titled],
            backing: .buffered,
            defer: false
        )
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .clear
        isOpaque = false
        ignoresMouseEvents = false
        becomesKeyOnlyIfNeeded = true
        level = .floating
    }

    override public var canBecomeKey: Bool {
        true
    }

    override public var canBecomeMain: Bool {
        false
    }

    override public var acceptsFirstResponder: Bool {
        true
    }

    override public func close() {
        closeHandler?()
        super.close()
    }

    override public func resignKey() {
        close()
    }
}

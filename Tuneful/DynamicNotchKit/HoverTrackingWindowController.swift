//
//  HoverTrackingWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 26/11/2024.
//

import SwiftUI
import Cocoa

public class HoverTrackingWindowController: NSWindowController {
    public override func windowDidLoad() {
        super.windowDidLoad()
        
        // Add a tracking area to the content view of the window
        if let contentView = window?.contentView {
            let trackingArea = NSTrackingArea(
                rect: contentView.bounds,
                options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow],
                owner: self,
                userInfo: nil
            )
            contentView.addTrackingArea(trackingArea)
        }
    }
    
    public override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        print("Mouse entered")
    }
    
    public override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        print("Mouse exited")
    }
}

//
//  HoverTrackingWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 26/11/2024.
//

import Cocoa

class HoverTrackingWindow: NSWindow {
    private var trackingArea: NSTrackingArea?
    
    override func updateTrackingArea() {
        super.updateTrackingAreas()
        
        // Remove existing tracking area if it exists
        if let trackingArea = trackingArea {
            self.contentView?.removeTrackingArea(trackingArea)
        }
        
        // Create a new tracking area
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow]
        trackingArea = NSTrackingArea(rect: self.contentView?.bounds ?? .zero,
                                      options: options,
                                      owner: self,
                                      userInfo: nil)
        
        // Add the tracking area to the content view
        if let trackingArea = trackingArea {
            self.contentView?.addTrackingArea(trackingArea)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        print("Mouse entered window")
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        print("Mouse exited window")
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        print("Mouse moved in window")
    }
}


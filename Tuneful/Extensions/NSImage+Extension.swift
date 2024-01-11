//
//  NSImage+Extension.swift
//  Tuneful
//
//  Created by Martin Fekete on 11/01/2024.
//

import Foundation
import AppKit

extension NSImage {
    func isEmpty() -> Bool {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let dataProvider = cgImage.dataProvider else { return true }
        let pixelData = dataProvider.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let imageWidth = Int(self.size.width)
        let imageHeight = Int(self.size.height)
        for x in 0..<imageWidth {
            for y in 0..<imageHeight {
                let pixelIndex = ((imageWidth * y) + x) * 4
                let r = data[pixelIndex]
                let g = data[pixelIndex + 1]
                let b = data[pixelIndex + 2]
                let a = data[pixelIndex + 3]
                if a != 0 {
                    if r != 0 || g != 0 || b != 0 { return false }
                }
            }
        }
        return true
    }
    
    func roundImage(withSize imageSize: NSSize, radius: CGFloat) -> NSImage {
        let imageFrame = NSRect(origin: .zero, size: imageSize)

        let newImage = NSImage(size: imageSize)
        newImage.lockFocus()
        NSGraphicsContext.saveGraphicsState()

        let path = NSBezierPath(roundedRect: imageFrame, xRadius: radius, yRadius: radius)
        path.addClip()

        self.size = imageFrame.size
        self.draw(in: imageFrame, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0, respectFlipped: true, hints: nil)

        NSGraphicsContext.restoreGraphicsState()

        newImage.unlockFocus()

        return newImage
    }
}


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
    
    var averageColor: NSColor? {
        if !isValid { return nil }
        
        // Create a CGImage from the NSImage
        var imageRect = CGRect(
            x: 0,
            y: 0,
            width: self.size.width,
            height: self.size.height
        )
        let cgImageRef = self.cgImage(
            forProposedRect: &imageRect,
            context: nil,
            hints: nil
        )
        
        // Create vector and apply filter
        let inputImage = CIImage(cgImage: cgImageRef!)
        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )
        
        let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: inputImage,
                kCIInputExtentKey: extentVector
            ]
        )
        let outputImage = filter!.outputImage!
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )
        
        return NSColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: CGFloat(bitmap[3]) / 255
        )
    }
}


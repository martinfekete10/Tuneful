//
//  Color+Extensions.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import AppKit
import SwiftUI

// Extension to add functionality to SwiftUI's Color type
public extension Color {
    static let violet = Color(red: 0.56, green: 0, blue: 1)

    // Initialize with HEX value, supporting both 3 and 6 characters
    init?(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        let expandedHex: String = if hexSanitized.count == 3 {
            hexSanitized.map { "\($0)\($0)" }.joined()
        } else {
            hexSanitized
        }

        let rgbValue = UInt64(expandedHex, radix: 16) ?? 0

        if rgbValue == 0, expandedHex != "000000" {
            NSLog("Invalid HEX value provided: \(hex)")
            return nil
        }

        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }

    // Convert to HEX representation
    func toHex() -> String {
        let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? .black
        return String(
            format: "#%02X%02X%02X", Int(nsColor.redComponent * 255), Int(nsColor.greenComponent * 255),
            Int(nsColor.blueComponent * 255)
        )
    }

    // Convert to RGB values
    func toRGB() -> (red: Double, green: Double, blue: Double) {
        let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? .black
        return (
            Double(nsColor.redComponent * 255), Double(nsColor.greenComponent * 255),
            Double(nsColor.blueComponent * 255)
        )
    }

    // Mix with another color
    func mixed(with other: Color, amount: CGFloat) -> Color {
        guard amount >= 0, amount <= 1 else {
            NSLog("Invalid mix amount: \(amount). Amount must be between 0 and 1.")
            return self
        }
        let blend = { (c1: CGFloat, c2: CGFloat) -> CGFloat in c1 + (c2 - c1) * amount }
        let selfComponents = components
        let otherComponents = other.components
        return Color(
            red: blend(selfComponents.red, otherComponents.red),
            green: blend(selfComponents.green, otherComponents.green),
            blue: blend(selfComponents.blue, otherComponents.blue)
        )
    }

    // Extract RGBA components
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let nsColor = NSColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }

    // Adjust the brightness of the color
    func brightnessAdjustment(brightness: Double) -> Color {
        let hsb = toHSB()
        // Ensure the new brightness is within the range [0, 1]
        let adjustedBrightness = max(0.0, min(brightness, 1.0))
        return Color(
            hue: Double(hsb.hue), saturation: Double(hsb.saturation), brightness: adjustedBrightness
        )
    }

    // Convert color to HSB values
    func toHSB() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? NSColor.black
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        nsColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue, saturation, brightness)
    }
}

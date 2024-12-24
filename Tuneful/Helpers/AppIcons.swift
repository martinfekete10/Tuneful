//
//  AppIcons.swift
//  Tuneful
//
//  Created by Harsh Vardhan Goswami on 16/08/24: https://github.com/TheBoredTeam/boring.notch
//  Modified by Martin Fekete
//

import SwiftUI
import AppKit

struct AppIcons {
    func getIcon(file path: URL) -> NSImage? {
        guard FileManager.default.fileExists(atPath: path.path())
        else { return nil }
        
        return NSWorkspace.shared.icon(forFile: path.path())
    }
    
    func getIcon(bundleID: String) -> NSImage? {
        guard let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
        else { return nil }
        
        return getIcon(file: path)
    }
}

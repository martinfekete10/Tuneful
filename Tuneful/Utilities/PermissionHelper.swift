//
//  Helper.swift
//  Tuneful
//
//  Created by Martin Fekete on 03/08/2023.
//

import Foundation

class PermissionHelper {
    enum PermissionStatus {
        case closed, granted, notPrompted, denied
    }
    
    static func promptUserForConsent(for appBundleID: String) -> PermissionStatus {
        
        let target = NSAppleEventDescriptor(bundleIdentifier: appBundleID)
        let status = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true)
        
        switch status {
        case -600:
            print("The application with BundleID: \(appBundleID) is not open.")
            return .closed
        case -0:
            print("Permissions granted for the application with BundleID: \(appBundleID).")
            return .granted
        case -1744:
            print("User consent required but not prompted for the application with BundleID: \(appBundleID).")
            return .notPrompted
        default:
            print("The user has declined permission for the application with BundleID: \(appBundleID).")
            return .denied
        }
    }
}

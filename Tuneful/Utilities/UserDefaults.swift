//
//  UserDefaults.swift
//  Tuneful
//
//  Source: [Jukebox](https://github.com/Jaysce/Jukebox)
//

import Foundation

extension UserDefaults {
    @objc dynamic var connectedApp: String {
        return string(forKey: "connectedApp")!
    }
}

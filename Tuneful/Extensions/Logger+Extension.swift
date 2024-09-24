//
//  Logger+Extension.swift
//  Tuneful
//
//  Created by Martin Fekete on 24/09/2024.
//

import os
import Foundation

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let main = Logger(subsystem: subsystem, category: "Debug")
}

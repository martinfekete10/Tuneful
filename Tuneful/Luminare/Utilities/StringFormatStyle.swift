//
//  StringFormatStyle.swift
//
//
//  Created by KrLite on 2024/7/7.
//

import SwiftUI

public struct StringFormatStyle: Codable, Equatable, Hashable, ParseableFormatStyle {
    public var parseStrategy: Strategy = .identity

    public typealias FormatInput = String
    public typealias FormatOutput = String

    public enum Strategy: Codable, Equatable, Hashable, ParseStrategy {
        public typealias ParseInput = String
        public typealias ParseOutput = String

        case identity
        case hex(HexStrategy)

        public func parse(_ value: String) throws -> String {
            switch self {
            case .identity:
                value
            case let .hex(strategy):
                try strategy.parse(value)
            }
        }
    }

    public enum HexStrategy: Codable, Equatable, Hashable, ParseStrategy {
        public typealias ParseInput = String
        public typealias ParseOutput = String

        /// `#42ab0E` -> `42ab0e`
        case lowercased

        /// `#42ab0E` -> `42AB0E`
        case uppercased

        /// `42ab0E` -> `#42ab0e`
        case lowercasedWithWell

        /// `42ab0E` -> `#42AB0E`
        case uppercasedWithWell

        public func parse(_ value: String) throws -> String {
            switch self {
            case .lowercased:
                value.lowercased()
                    .replacing(#/[^a-f0-9]/#, with: "")
            case .uppercased:
                value.uppercased()
                    .replacing(#/[^A-F0-9]/#, with: "")
            case .lowercasedWithWell:
                try "#" + Self.lowercased.parse(value)
            case .uppercasedWithWell:
                try "#" + Self.uppercased.parse(value)
            }
        }
    }

    public func format(_ value: String) -> String {
        do {
            return try parseStrategy.parse(value)
        } catch {
            print("Error: \(error)")
            return value
        }
    }
}

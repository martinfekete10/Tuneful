//
//  Comparable+Extension.swift
//  Tuneful
//
//  Created by Martin Fekete on 11/01/2024.
//

import Foundation

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(range.upperBound, max(range.lowerBound, self))
    }
}

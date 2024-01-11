//
//  CGFloat+Extension.swift
//  Tuneful
//
//  Created by Martin Fekete on 11/01/2024.
//

import Foundation

extension CGFloat {
    func map(
        from old: ClosedRange<CGFloat>,
        to new: ClosedRange<CGFloat>
    ) -> CGFloat {
        let oldMagnitude = old.upperBound - old.lowerBound
        let newPercent = (self - old.lowerBound) / oldMagnitude
        let newMagnitude = new.upperBound - new.lowerBound
        let result = newPercent * newMagnitude + new.lowerBound
        return result.isFinite ? result : 0
    }
}

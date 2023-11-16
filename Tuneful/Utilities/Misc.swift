//
//  Misc.swift
//  Tuneful
//
//  Created by Martin Fekete on 18/08/2023.
//

import Foundation
import Combine
import SwiftUI
import AppKit

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(range.upperBound, max(range.lowerBound, self))
    }
}

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

extension Color {
    static let playbackPositionLeadingRectangle = Color.init(
        NSColor(named: .init("playbackPositionLeadingRectangle"))!
    )
    
    static let sliderTrailingRectangle = Color.init(
        NSColor(named: .init("sliderTrailingRectangle"))!
    )
}


extension DateComponentsFormatter {
    static let playbackTimeWithHours: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    static let playbackTime: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}

extension NSError {
    static func checkOSStatus(_ closure: () -> OSStatus) throws {
      guard let error = NSError(osstatus: closure()) else {
          return
      }

      throw error
    }

    convenience init?(osstatus: OSStatus) {
        guard osstatus != 0 else {
            return nil
        }

        self.init(domain: NSOSStatusErrorDomain, code: Int(osstatus), userInfo: nil)
    }
}

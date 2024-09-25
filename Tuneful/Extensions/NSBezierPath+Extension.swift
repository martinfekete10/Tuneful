//
//  NSBezierPath+Extension.swift
//  Tuneful
//
//  Created by Martin Fekete on 24/09/2024.
//

import SwiftUI

extension NSBezierPath {
    func transformToCGPath() -> CGPath {
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        
        for i in 0..<elementCount {
            let element = element(at: i, associatedPoints: points)
            switch element {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .closePath:
                path.closeSubpath()
            case .cubicCurveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .quadraticCurveTo:
                path.addQuadCurve(to: points[1], control: points[0])
            @unknown default:
                break
            }
        }
        
        points.deallocate()
        return path
    }
}

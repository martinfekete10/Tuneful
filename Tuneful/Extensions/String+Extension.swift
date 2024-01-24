//
//  String+Extension.swift
//  Tuneful
//
//  Created by Martin Fekete on 24/01/2024.
//

import Foundation
import AppKit

extension String {
    func stringWidth(with font: NSFont) -> CGFloat {
        let attributes = [ NSAttributedString.Key.font: font ]
        return self.size(withAttributes: attributes).width
    }
    
    func stringHeight(with font: NSFont) -> CGFloat {
        let attributes = [ NSAttributedString.Key.font: font ]
        return self.size(withAttributes: attributes).height
    }
    
}

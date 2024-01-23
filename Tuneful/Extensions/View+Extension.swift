//
//  View+Extension.swift
//  Tuneful
//
//  Created by Martin Fekete on 17/01/2024.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func dragWindowWithClick() -> some View {
        self.overlay(DragWindowNSRepr())
    }
}

fileprivate struct DragWindowNSRepr: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        return DragWndNSView()
    }
    
    func updateNSView(_ nsView: NSView, context: Context) { }
}

fileprivate class DragWndNSView: NSView {
    override public func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

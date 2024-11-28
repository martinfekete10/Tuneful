//
//  ScrollWheelModifier.swift
//  Tuneful
//
//  Created by Martin Fekete on 27/11/2024.
//

import SwiftUI
import Combine

struct ScrollWheelModifier: ViewModifier {
    enum Direction {
        case up, down, left, right
    }

    @State private var subs = Set<AnyCancellable>() // Cancel onDisappear

    var action: (Direction) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear { trackScrollWheel() }
    }
    
    func trackScrollWheel() {
        NSApp.publisher(for: \.currentEvent)
            .filter { event in event?.type == .scrollWheel }
            .throttle(for: .milliseconds(200),
                      scheduler: DispatchQueue.main,
                      latest: true)
            .sink {
                if let event = $0 {
                    if event.deltaX > 0 {
                        action(.right)
                    }
                    
                    if event.deltaX < 0 {
                        action(.left)
                    }
                    
                    if event.deltaY > 0 {
                        action(.down)
                    }
                    
                    if event.deltaY < 0 {
                        action(.up)
                    }
                }
            }
            .store(in: &subs)
    }
}

extension View {
    func onScrollWheelUp(action: @escaping (ScrollWheelModifier.Direction) -> Void) -> some View {
        modifier(ScrollWheelModifier(action: action) )
    }
}

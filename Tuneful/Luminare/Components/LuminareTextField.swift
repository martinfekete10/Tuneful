//
//  LuminareTextField.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

public struct LuminareTextField<F>: View where F: ParseableFormatStyle, F.FormatOutput == String {
    let elementMinHeight: CGFloat = 34
    let horizontalPadding: CGFloat = 8

    @Binding var value: F.FormatInput?
    var format: F
    let placeholder: LocalizedStringKey
    let onSubmit: (() -> ())?

    @State var monitor: Any?

    public init(_ placeholder: LocalizedStringKey, value: Binding<F.FormatInput?>, format: F, onSubmit: (() -> ())? = nil) {
        self._value = value
        self.format = format
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    public init(_ placeholder: LocalizedStringKey, text: Binding<String>, onSubmit: (() -> ())? = nil) where F == StringFormatStyle {
        self.init(placeholder, value: .init(text), format: StringFormatStyle(), onSubmit: onSubmit)
    }

    public var body: some View {
        TextField(placeholder, value: $value, format: format)
            .padding(.horizontal, horizontalPadding)
            .frame(minHeight: elementMinHeight)
            .textFieldStyle(.plain)
            .onSubmit {
                if let onSubmit {
                    onSubmit()
                }
            }

            .onAppear {
                guard monitor != nil else { return }

                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if let window = NSApp.keyWindow, window.animationBehavior == .documentWindow {
                        window.keyDown(with: event)

                        // Fixes cmd+w to close window.
                        let wKey = 13
                        if event.keyCode == wKey, event.modifierFlags.contains(.command) {
                            return nil
                        }
                    }
                    return event
                }
            }
            .onDisappear {
                if let monitor {
                    NSEvent.removeMonitor(monitor)
                }
                monitor = nil
            }
    }
}

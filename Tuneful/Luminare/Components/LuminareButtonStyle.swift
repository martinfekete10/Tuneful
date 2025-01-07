//
//  LuminareButtonStyle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    @State var isHovering: Bool = false

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundForState(isPressed: configuration.isPressed))
            .onHover { hover in
                withAnimation(LuminareConstants.fastAnimation) {
                    isHovering = hover
                }
            }
            .animation(LuminareConstants.fastAnimation, value: isHovering)
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .opacity(isEnabled ? 1 : 0.5)
    }

    private func backgroundForState(isPressed: Bool) -> some View {
        Group {
            if isPressed, isEnabled {
                Rectangle().foregroundStyle(.quaternary)
            } else if isHovering, isEnabled {
                Rectangle().foregroundStyle(.quaternary.opacity(0.7))
            } else {
                Rectangle().foregroundStyle(.quinary)
            }
        }
    }
}

public struct LuminareDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    @State var isHovering: Bool = false

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(destructiveBackgroundForState(isPressed: configuration.isPressed))
            .onHover { hover in
                withAnimation(LuminareConstants.fastAnimation) {
                    isHovering = hover
                }
            }
            .animation(LuminareConstants.fastAnimation, value: isHovering)
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .opacity(isEnabled ? 1 : 0.5)
    }

    private func destructiveBackgroundForState(isPressed: Bool) -> some View {
        Group {
            if isPressed, isEnabled {
                Rectangle().foregroundStyle(.red.opacity(0.4))
            } else if isHovering, isEnabled {
                Rectangle().foregroundStyle(.red.opacity(0.25))
            } else {
                Rectangle().foregroundStyle(.red.opacity(0.15))
            }
        }
    }
}

public struct LuminareCosmeticButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    @State var isHovering: Bool = false
    let icon: Image

    public init(_ icon: Image) {
        self.icon = icon
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundForState(isPressed: configuration.isPressed))
            .onHover { hover in
                withAnimation(LuminareConstants.fastAnimation) {
                    isHovering = hover
                }
            }
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .opacity(isEnabled ? 1 : 0.5)
            .overlay {
                HStack {
                    Spacer()
                    icon
                        .opacity(isHovering ? 1 : 0)
                }
                .padding(24)
                .allowsHitTesting(false)
            }
    }

    private func backgroundForState(isPressed: Bool) -> some View {
        Group {
            if isPressed, isEnabled {
                Rectangle().foregroundStyle(.quaternary)
            } else if isHovering, isEnabled {
                Rectangle().foregroundStyle(.quaternary.opacity(0.7))
            }
        }
    }
}

public struct LuminareCompactButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    let elementMinHeight: CGFloat = 34
    let elementExtraMinHeight: CGFloat = 25
    let extraCompact: Bool
    @State var isHovering: Bool = false
    let cornerRadius: CGFloat = 8

    public init(extraCompact: Bool = false) {
        self.extraCompact = extraCompact
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, extraCompact ? 0 : 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundForState(isPressed: configuration.isPressed))
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
            .fixedSize(horizontal: extraCompact, vertical: extraCompact)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .onHover { hover in
                withAnimation(LuminareConstants.fastAnimation) {
                    isHovering = hover
                }
            }
            .animation(LuminareConstants.fastAnimation, value: isHovering)
            .frame(minHeight: extraCompact ? elementExtraMinHeight : elementMinHeight)
            .opacity(isEnabled ? 1 : 0.5)
    }

    private func backgroundForState(isPressed: Bool) -> some View {
        Group {
            if isPressed {
                Rectangle().foregroundStyle(.quaternary)
            } else if isHovering {
                Rectangle().foregroundStyle(.quaternary.opacity(0.7))
            } else {
                Rectangle().foregroundStyle(.quinary)
            }
        }
    }
}

public struct LuminareBordered: ViewModifier {
    @Binding var highlight: Bool
    let cornerRadius: CGFloat = 8

    public init(highlight: Binding<Bool> = .constant(false)) {
        self._highlight = highlight
    }

    public func body(content: Content) -> some View {
        content
            .background {
                if highlight {
                    Rectangle().foregroundStyle(.quaternary.opacity(0.7))
                } else {
                    Rectangle().foregroundStyle(.quinary)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
    }
}

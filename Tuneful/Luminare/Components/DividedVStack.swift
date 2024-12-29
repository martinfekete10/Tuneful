//
//  DividedVStack.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//
// Thank you https://movingparts.io/variadic-views-in-swiftui

import SwiftUI

public struct DividedVStack<Content: View>: View {
    let spacing: CGFloat?
    let applyMaskToItems: Bool
    let showDividers: Bool
    var content: Content

    public init(spacing: CGFloat? = nil, applyMaskToItems: Bool = true, showDividers: Bool = true, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.applyMaskToItems = applyMaskToItems
        self.showDividers = showDividers
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(
            DividedVStackLayout(
                spacing: applyMaskToItems ? spacing : 0,
                applyMaskToItems: applyMaskToItems,
                showDividers: showDividers
            )
        ) {
            content
        }
    }
}

struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
    let spacing: CGFloat
    let applyMaskToItems: Bool
    let showDividers: Bool

    let innerPadding: CGFloat = 4

    init(spacing: CGFloat?, applyMaskToItems: Bool, showDividers: Bool) {
        self.spacing = spacing ?? innerPadding
        self.applyMaskToItems = applyMaskToItems
        self.showDividers = showDividers
    }

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: showDividers ? spacing : spacing / 2) {
            ForEach(children) { child in
                Group {
                    if applyMaskToItems {
                        child
                            .modifier(
                                LuminareCroppedSectionItem(
                                    isFirstChild: child.id == first,
                                    isLastChild: child.id == last
                                )
                            )
                            .padding(.top, child.id == first ? 1 : 0)
                            .padding(.bottom, child.id == last ? 1 : 0)
                            .padding(.horizontal, 1)
                    } else {
                        child
                            .mask(Rectangle()) // Fixes hover areas for some reason
                            .padding(.vertical, -4)
                    }
                }

                if showDividers, child.id != last {
                    Divider()
                        .padding(.horizontal, 1)
                }
            }
        }
        .padding(.vertical, innerPadding)
    }
}

public struct LuminareCroppedSectionItem: ViewModifier {
    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let innerCornerRadius: CGFloat = 2

    let isFirstChild: Bool
    let isLastChild: Bool

    public init(isFirstChild: Bool, isLastChild: Bool) {
        self.isFirstChild = isFirstChild
        self.isLastChild = isLastChild
    }

    public func body(content: Content) -> some View {
        content
            .mask(getMask())
            .padding(.horizontal, innerPadding)
    }

    func getMask() -> some View {
        if isFirstChild, isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: cornerRadius - innerPadding
            )
        } else if isFirstChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding
            )
        } else if isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: innerCornerRadius
            )
        } else {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        }
    }
}

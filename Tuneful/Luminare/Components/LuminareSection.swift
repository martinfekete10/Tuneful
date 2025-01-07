//
//  LuminareSection.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

public struct LuminareSection<Content: View>: View {
    let headerSpacing: CGFloat = 8
    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4

    let header: LocalizedStringKey?
    let disablePadding: Bool
    let showDividers: Bool
    let noBorder: Bool
    let content: () -> Content

    public init(_ header: LocalizedStringKey? = nil, disablePadding: Bool = false, showDividers: Bool = true, noBorder: Bool = false, @ViewBuilder _ content: @escaping () -> Content) {
        self.header = header
        self.disablePadding = disablePadding
        self.showDividers = showDividers
        self.noBorder = noBorder
        self.content = content
    }

    public var body: some View {
        VStack(spacing: headerSpacing) {
            if let header {
                HStack {
                    Text(header)
                    Spacer()
                }
                .foregroundStyle(.secondary)
            }

            if noBorder {
                content()
            } else {
                DividedVStack(applyMaskToItems: !disablePadding, showDividers: showDividers) {
                    content()
                }
                .frame(maxWidth: .infinity)
                .background(.quinary)
                .clipShape(.rect(cornerRadius: cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(.quaternary, lineWidth: 1)
                }
            }
        }
    }
}

//
//  LuminareToggle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareToggle: View {
    @Environment(\.tintColor) var tintColor

    let elementMinHeight: CGFloat = 34
    let horizontalPadding: CGFloat = 8

    let title: LocalizedStringKey
    let infoView: LuminareInfoView?
    @Binding var value: Bool

    let disabled: Bool
    @State var isShowingDescription: Bool = false

    public init(
        _ title: LocalizedStringKey,
        info: LuminareInfoView? = nil,
        isOn value: Binding<Bool>,
        disabled: Bool = false
    ) {
        self.title = title
        self.infoView = info
        self._value = value
        self.disabled = disabled
    }

    public var body: some View {
        HStack {
            HStack(spacing: 0) {
                Text(title)

                if let infoView {
                    infoView
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Toggle("", isOn: $value.animation(LuminareConstants.animation))
                .labelsHidden()
                .controlSize(.small)
                .toggleStyle(.switch)
                .disabled(disabled)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(minHeight: elementMinHeight)
    }
}

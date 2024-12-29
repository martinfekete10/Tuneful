//
//  LuminareSliderPicker.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public struct LuminareSliderPicker<V>: View where V: Equatable {
    let height: CGFloat = 70

    let title: LocalizedStringKey

    let options: [V]
    @Binding var selection: V

    let label: (V) -> LocalizedStringKey

    let horizontalPadding: CGFloat = 8

    public init(_ title: LocalizedStringKey, _ options: [V], selection: Binding<V>, label: @escaping (V) -> LocalizedStringKey) {
        self.title = title
        self.options = options
        self._selection = selection
        self.label = label
    }

    public var body: some View {
        VStack {
            HStack {
                Text(title)

                Spacer()

                labelView()
            }

            Slider(
                value: Binding<Double>(
                    get: {
                        Double(options.firstIndex(where: { $0 == selection }) ?? 0)
                    },
                    set: { newIndex in
                        selection = options[Int(newIndex)]
                    }
                ),
                in: 0...Double(options.count - 1),
                step: 1
            )
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: height)
        .animation(LuminareConstants.animation, value: selection)
    }

    @ViewBuilder
    func labelView() -> some View {
        HStack {
            Text(label(selection))
                .contentTransition(.numericText())
                .multilineTextAlignment(.trailing)
                .monospaced()
                .padding(4)
                .padding(.horizontal, 4)
                .background {
                    ZStack {
                        Capsule()
                            .strokeBorder(.quaternary, lineWidth: 1)

                        Capsule()
                            .foregroundStyle(.quinary.opacity(0.5))
                    }
                }
                .fixedSize()
                .clipShape(.capsule)
        }
    }
}
